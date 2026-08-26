from sqlalchemy import Column, String, Boolean, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base


class NotificationPreference(Base):
    __tablename__ = "notification_preferences"

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id"),
        primary_key=True,
    )

    price_increase = Column(Boolean, nullable=False, default=True)
    price_drop = Column(Boolean, nullable=False, default=True)
    better_market = Column(Boolean, nullable=False, default=True)
    market_glut = Column(Boolean, nullable=False, default=True)
    ai_recommendation = Column(Boolean, nullable=False, default=True)

    delivery_in_app = Column(Boolean, nullable=False, default=True)
    delivery_email = Column(Boolean, nullable=False, default=False)
    delivery_push = Column(Boolean, nullable=False, default=False)

    frequency = Column(String(20), nullable=False, default="instant")

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
    )
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )

    user = relationship(
        "User",
        back_populates="notification_preferences",
    )
