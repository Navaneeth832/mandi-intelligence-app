from pydantic import BaseModel
from datetime import date


class MandiPriceItemSchema(BaseModel):
    state: str
    state_id: int
    district: str
    district_id: int
    market: str
    market_id: int
    commodity: str
    commodity_id: int
    translated_name: str | None = None
    variety: str
    grade: str
    modal_price: float
    min_price: float
    max_price: float
    arrival_date: date
    created_at: str
    commodity_image_url: str

    class Config:
        from_attributes = True


class MandiPriceResponseSchema(BaseModel):
    page: int
    page_size: int
    total_records: int
    total_pages: int
    data: list[MandiPriceItemSchema]
