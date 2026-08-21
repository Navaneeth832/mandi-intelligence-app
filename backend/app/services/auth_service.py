from uuid import uuid4

from sqlalchemy import or_
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.user import User
from app.schemas.user import (
    SendOTPRequest,
    UserRegister,
    UserLogin,
    VerifyOTPRequest,
    ResetPasswordRequest,
)
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
)
from app.services.otp_service import OTPService
from app.services.verification_token_service import VerificationTokenService
from app.utils.auth_identifiers import IdentifierType, normalize_identifier

REGISTRATION_PURPOSE = "registration"
RESET_PASSWORD_PURPOSE = "reset_password"



class AuthService:
    """Authentication use cases for OTP registration and JWT login."""

    @staticmethod
    def send_otp(db: Session, request: SendOTPRequest) -> dict[str, str]:
        """Create and send an OTP for a new email or phone registration."""

        identifier, identifier_type = normalize_identifier(request.identifier)

        if AuthService._get_user_by_identifier(db, identifier):
            raise ValueError("User already registered")

        otp = OTPService.create_otp(
            db,
            identifier,
            REGISTRATION_PURPOSE,
        )

        if identifier_type == IdentifierType.EMAIL:
            OTPService.send_email_otp(identifier, otp)
        else:
            OTPService.send_sms_otp(identifier, otp)

        return {
            "message": "OTP sent successfully",
            "identifier": identifier,
            "registration_method": identifier_type.value,
        }

    @staticmethod
    def verify_otp(db: Session, request: VerifyOTPRequest) -> dict[str, object]:
        """Verify an OTP and return a short-lived registration token."""

        identifier, _ = normalize_identifier(request.identifier)

        if AuthService._get_user_by_identifier(db, identifier):
            raise ValueError("User already registered")

        OTPService.verify_otp(
            db,
            identifier,
            request.otp,
            REGISTRATION_PURPOSE,
        )

        verification_token = VerificationTokenService.create_verification_token(
            db,
            identifier,
            REGISTRATION_PURPOSE,
        )

        return {
            "verification_token": verification_token,
            "token_type": "registration_verification",
            "expires_in_seconds": VerificationTokenService.TOKEN_EXPIRY_MINUTES * 60,
        }

    @staticmethod
    def register(db: Session, user_data: UserRegister) -> User:
        """Create a verified user after validating the verification token."""

        identifier, identifier_type = normalize_identifier(user_data.identifier)

        if AuthService._get_user_by_identifier(db, identifier):
            raise ValueError("User already registered")

        verification_token = VerificationTokenService.verify_verification_token(
            db,
            identifier,
            user_data.verification_token,
            REGISTRATION_PURPOSE,
        )

        user = User(
            id=uuid4(),
            name=user_data.name,
            email=identifier if identifier_type == IdentifierType.EMAIL else None,
            phone_number=identifier if identifier_type == IdentifierType.PHONE else None,
            password_hash=hash_password(user_data.password),
            state_id=user_data.state_id,
            district_id=user_data.district_id,
            preferred_market_id=user_data.preferred_market_id,
            preferred_language=user_data.preferred_language,
            registration_method=identifier_type.value,
            is_verified=True,
        )

        db.add(user)

        try:
            db.commit()
        except IntegrityError as exc:
            db.rollback()
            raise ValueError("User already registered") from exc

        VerificationTokenService.invalidate_token(db, verification_token)
        db.refresh(user)

        return user

    @staticmethod
    def login(db: Session, user_data: UserLogin) -> dict[str, object]:
        """Authenticate by email or phone and issue the existing JWT."""

        identifier, _ = normalize_identifier(user_data.identifier)
        user = AuthService._get_user_by_identifier(db, identifier)

        if not user:
            raise ValueError("Invalid identifier or password")

        if not verify_password(
            user_data.password,
            user.password_hash,
        ):
            raise ValueError("Invalid identifier or password")

        token = create_access_token(
            {
                "sub": str(user.id)
            }
        )

        return {
            "access_token": token,
            "token_type": "bearer",
            "user": user,
        }

    @staticmethod
    def send_forgot_password_otp(db: Session, request: SendOTPRequest) -> dict[str, str]:
        """Create and send an OTP for password reset of an existing user."""

        identifier, identifier_type = normalize_identifier(request.identifier)

        user = AuthService._get_user_by_identifier(db, identifier)
        if not user:
            raise ValueError("No account found registered with this email or mobile number")

        otp = OTPService.create_otp(
            db,
            identifier,
            RESET_PASSWORD_PURPOSE,
        )

        if identifier_type == IdentifierType.EMAIL:
            OTPService.send_email_otp(identifier, otp)
        else:
            OTPService.send_sms_otp(identifier, otp)

        return {
            "message": "OTP sent successfully",
            "identifier": identifier,
            "registration_method": identifier_type.value,
        }

    @staticmethod
    def verify_forgot_password_otp(db: Session, request: VerifyOTPRequest) -> dict[str, object]:
        """Verify password reset OTP and issue transient reset verification token."""

        identifier, _ = normalize_identifier(request.identifier)

        user = AuthService._get_user_by_identifier(db, identifier)
        if not user:
            raise ValueError("No account found registered with this email or mobile number")

        OTPService.verify_otp(
            db,
            identifier,
            request.otp,
            RESET_PASSWORD_PURPOSE,
        )

        verification_token = VerificationTokenService.create_verification_token(
            db,
            identifier,
            RESET_PASSWORD_PURPOSE,
        )

        return {
            "verification_token": verification_token,
            "token_type": "reset_password_verification",
            "expires_in_seconds": VerificationTokenService.TOKEN_EXPIRY_MINUTES * 60,
        }

    @staticmethod
    def reset_password(db: Session, request: ResetPasswordRequest) -> dict[str, str]:
        """Reset user password after validating the password reset verification token."""

        identifier, _ = normalize_identifier(request.identifier)

        user = AuthService._get_user_by_identifier(db, identifier)
        if not user:
            raise ValueError("No account found registered with this email or mobile number")

        verification_token = VerificationTokenService.verify_verification_token(
            db,
            identifier,
            request.verification_token,
            RESET_PASSWORD_PURPOSE,
        )

        user.password_hash = hash_password(request.new_password)
        VerificationTokenService.invalidate_token(db, verification_token)

        try:
            db.commit()
        except Exception as exc:
            db.rollback()
            raise ValueError("Failed to update password. Please try again.") from exc

        return {"message": "Password reset successfully"}


    @staticmethod
    def _get_user_by_identifier(
        db: Session,
        identifier: str,
    ) -> User | None:
        return (
            db.query(User)
            .filter(
                or_(
                    User.email == identifier,
                    User.phone_number == identifier,
                )
            )
            .first()
        )
