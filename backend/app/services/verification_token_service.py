import secrets
from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.verification_token import VerificationToken


class VerificationTokenService:
    """Issues and verifies hashed single-use registration tokens."""

    TOKEN_EXPIRY_MINUTES = 10

    @staticmethod
    def generate_token() -> str:
        """Generate a cryptographically secure URL-safe token."""

        return secrets.token_urlsafe(32)

    @staticmethod
    def hash_token(token: str) -> str:
        """Hash a verification token with bcrypt before persistence."""

        return hash_password(token)

    @staticmethod
    def create_verification_token(
        db: Session,
        identifier: str,
        purpose: str,
    ) -> str:
        """Invalidate old unused tokens and create a fresh verification token."""

        db.query(VerificationToken).filter(
            VerificationToken.identifier == identifier,
            VerificationToken.purpose == purpose,
            VerificationToken.used.is_(False),
        ).update(
            {VerificationToken.used: True},
            synchronize_session=False,
        )

        token = VerificationTokenService.generate_token()
        verification_token = VerificationToken(
            identifier=identifier,
            token_hash=VerificationTokenService.hash_token(token),
            purpose=purpose,
            expires_at=datetime.now(timezone.utc)
            + timedelta(minutes=VerificationTokenService.TOKEN_EXPIRY_MINUTES),
            used=False,
        )

        db.add(verification_token)
        db.commit()

        return token

    @staticmethod
    def verify_verification_token(
        db: Session,
        identifier: str,
        token: str,
        purpose: str,
    ) -> VerificationToken:
        """Verify a valid unused token without marking it used."""

        verification_tokens = (
            db.query(VerificationToken)
            .filter(
                VerificationToken.identifier == identifier,
                VerificationToken.purpose == purpose,
                VerificationToken.used.is_(False),
            )
            .order_by(VerificationToken.created_at.desc())
            .all()
        )

        for verification_token in verification_tokens:
            if _is_expired(verification_token.expires_at):
                verification_token.used = True
                continue

            if verify_password(token, verification_token.token_hash):
                db.commit()
                return verification_token

        db.commit()
        raise ValueError("Invalid or expired verification token")

    @staticmethod
    def invalidate_token(
        db: Session,
        verification_token: VerificationToken,
    ) -> None:
        """Mark a verification token as used."""

        verification_token.used = True
        db.commit()


def _is_expired(expires_at: datetime) -> bool:
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)

    return expires_at <= datetime.now(timezone.utc)
