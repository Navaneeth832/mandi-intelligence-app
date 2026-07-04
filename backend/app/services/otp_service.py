import logging
import secrets
from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session
from app.services.email_service import EmailService

from app.core.security import hash_password, verify_password
from app.models.otp_verification import OTPVerification

logger = logging.getLogger(__name__)


class OTPService:
    """Creates, sends, and verifies single-use OTP challenges."""

    OTP_EXPIRY_MINUTES = 5

    @staticmethod
    def generate_otp() -> str:
        """Generate a cryptographically secure six-digit OTP."""

        return f"{secrets.randbelow(1_000_000):06d}"

    @staticmethod
    def hash_otp(otp: str) -> str:
        """Hash an OTP with bcrypt before persistence."""

        return hash_password(otp)

    @staticmethod
    def create_otp(
        db: Session,
        identifier: str,
        purpose: str,
    ) -> str:
        """Invalidate previous unused OTPs and create a fresh challenge."""

        db.query(OTPVerification).filter(
            OTPVerification.identifier == identifier,
            OTPVerification.purpose == purpose,
            OTPVerification.used.is_(False),
        ).delete(synchronize_session=False)

        otp = OTPService.generate_otp()
        otp_verification = OTPVerification(
            identifier=identifier,
            otp_hash=OTPService.hash_otp(otp),
            purpose=purpose,
            expires_at=datetime.now(timezone.utc)
            + timedelta(minutes=OTPService.OTP_EXPIRY_MINUTES),
            used=False,
        )

        db.add(otp_verification)
        db.commit()

        return otp

    @staticmethod
    def verify_otp(
        db: Session,
        identifier: str,
        otp: str,
        purpose: str,
    ) -> bool:
        """Verify a valid unused OTP and mark it as used."""

        otp_verification = (
            db.query(OTPVerification)
            .filter(
                OTPVerification.identifier == identifier,
                OTPVerification.purpose == purpose,
                OTPVerification.used.is_(False),
            )
            .order_by(OTPVerification.created_at.desc())
            .first()
        )

        if otp_verification is None:
            raise ValueError("Invalid or expired OTP")

        if _is_expired(otp_verification.expires_at):
            otp_verification.used = True
            db.commit()
            raise ValueError("OTP has expired")

        if not verify_password(otp, otp_verification.otp_hash):
            raise ValueError("Invalid OTP")

        otp_verification.used = True
        db.commit()

        return True

    @staticmethod
    def send_email_otp(email: str, otp: str) -> None:
        EmailService.send_otp_email(email, otp)

    @staticmethod
    def send_sms_otp(phone_number: str, otp: str) -> None:
        """Development stub."""

        print("\n" + "=" * 60)
        print(f"DEV SMS OTP")
        print(f"Recipient : {phone_number}")
        print(f"OTP       : {otp}")
        print("=" * 60 + "\n")


def _is_expired(expires_at: datetime) -> bool:
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)

    return expires_at <= datetime.now(timezone.utc)
