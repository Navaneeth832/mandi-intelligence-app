from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base


class UserCropPreference(Base):
    __tablename__ = "user_crop_preferences"

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        primary_key=True
    )

    commodity_id = Column(
        Integer,
        ForeignKey("commodities.id"),
        primary_key=True
    )

    user = relationship(
        "User",
        back_populates="crop_preferences"
    )

    commodity = relationship("Commodity")