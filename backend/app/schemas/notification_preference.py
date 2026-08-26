from enum import Enum
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, ConfigDict


class NotificationFrequency(str, Enum):
    INSTANT = "instant"
    DAILY_SUMMARY = "daily_summary"


class NotificationPreferenceBase(BaseModel):
    price_increase: bool = True
    price_drop: bool = True
    better_market: bool = True
    market_glut: bool = True
    ai_recommendation: bool = True
    delivery_in_app: bool = True
    delivery_email: bool = False
    delivery_push: bool = False
    frequency: NotificationFrequency = NotificationFrequency.INSTANT


class NotificationPreferenceUpdate(BaseModel):
    price_increase: bool
    price_drop: bool
    better_market: bool
    market_glut: bool
    ai_recommendation: bool
    delivery_in_app: bool
    delivery_email: bool
    delivery_push: bool
    frequency: NotificationFrequency


class NotificationPreferenceResponse(BaseModel):
    user_id: UUID
    price_increase: bool
    price_drop: bool
    better_market: bool
    market_glut: bool
    ai_recommendation: bool
    delivery_in_app: bool
    delivery_email: bool
    delivery_push: bool
    frequency: str
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
