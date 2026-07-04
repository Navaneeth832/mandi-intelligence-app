from sqlalchemy import Boolean, CheckConstraint, Column, String, Integer, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    name = Column(String(100), nullable=False)

    email = Column(String(255), unique=True, nullable=True)

    phone_number = Column(String(20), unique=True, nullable=True)

    password_hash = Column(String, nullable=False)

    state_id = Column(Integer, ForeignKey("states.id"))

    district_id = Column(Integer, ForeignKey("districts.id"))

    preferred_language = Column(String(20), default="en")

    registration_method = Column(String(20), nullable=False)

    is_verified = Column(Boolean, nullable=False, default=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now()
    )

    state = relationship("State")
    district = relationship("District")
    
    @property
    def state_name(self):
        return self.state.name if self.state else None


    @property
    def district_name(self):
        return self.district.name if self.district else None

    crop_preferences = relationship(
        "UserCropPreference",
        back_populates="user",
        cascade="all, delete-orphan"
    )

    refresh_tokens = relationship(
        "RefreshToken",
        back_populates="user",
        cascade="all, delete-orphan"
    )

    __table_args__ = (
        CheckConstraint(
            "(email IS NOT NULL AND phone_number IS NULL) OR "
            "(email IS NULL AND phone_number IS NOT NULL)",
            name="ck_users_exactly_one_identifier",
        ),
        CheckConstraint(
            "registration_method IN ('email', 'phone')",
            name="ck_users_registration_method",
        ),
    )
