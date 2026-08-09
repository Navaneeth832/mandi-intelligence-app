from typing import Optional, List
from datetime import datetime
from uuid import UUID
from enum import Enum
from pydantic import BaseModel, Field

class AlertType(str, Enum):
    BETTER_MARKET = "BETTER_MARKET"
    PRICE_INCREASE = "PRICE_INCREASE"
    PRICE_DROP = "PRICE_DROP"
    AI_RECOMMENDATION = "AI_RECOMMENDATION"

class AlertSeverity(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"

class AlertCommoditySchema(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True

class AlertMarketSchema(BaseModel):
    id: int
    name: str

    class Config:
        from_attributes = True

class AlertPriceSchema(BaseModel):
    current: float
    previous: Optional[float] = None
    change_percent: Optional[float] = None

    class Config:
        from_attributes = True

class AlertSchema(BaseModel):
    id: int
    type: AlertType
    severity: AlertSeverity
    title: str
    message: str
    commodity: AlertCommoditySchema
    market: AlertMarketSchema
    price: Optional[AlertPriceSchema] = None
    created_at: datetime

    class Config:
        from_attributes = True

class PaginatedAlertsResponse(BaseModel):
    items: List[AlertSchema]
    page: int
    page_size: int
    total: int

class AlertCreateSchema(BaseModel):
    user_id: UUID
    type: AlertType
    severity: AlertSeverity = AlertSeverity.MEDIUM
    title: str
    message: str
    commodity_id: int
    market_id: int
    current_price: Optional[float] = None
    previous_price: Optional[float] = None
    change_percent: Optional[float] = None
