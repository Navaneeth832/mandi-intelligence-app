from pydantic import BaseModel
from datetime import date


class PriceHistoryResponse(BaseModel):
    arrival_date: date
    modal_price: float

    class Config:
        from_attributes = True