import re
from enum import StrEnum


class IdentifierType(StrEnum):
    EMAIL = "email"
    PHONE = "phone"


EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
PHONE_REGEX = re.compile(r"^\+?[1-9]\d{9,14}$")


def normalize_identifier(identifier: str) -> tuple[str, IdentifierType]:
    """Return a normalized email or phone identifier and its type."""

    raw_identifier = identifier.strip()
    if not raw_identifier:
        raise ValueError("Identifier is required")

    email = _normalize_email(raw_identifier)
    if email:
        return email, IdentifierType.EMAIL

    phone = _normalize_phone(raw_identifier)
    if phone:
        return phone, IdentifierType.PHONE

    raise ValueError("Identifier must be a valid email or phone number")


def _normalize_email(identifier: str) -> str | None:
    if EMAIL_REGEX.fullmatch(identifier):
        return identifier.lower()

    return None


def _normalize_phone(identifier: str) -> str | None:
    phone = re.sub(r"[\s().-]", "", identifier)

    if PHONE_REGEX.fullmatch(phone):
        return phone

    return None
