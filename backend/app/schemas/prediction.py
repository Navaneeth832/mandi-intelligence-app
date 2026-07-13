from pydantic import BaseModel
from typing import List

class ForecastDay(BaseModel):
    date: str
    price: float

    class Config:
        from_attributes = True

class ForecastResponse(BaseModel):
    commodity_id: int
    commodity_name: str
    prediction_date: str
    prediction_time: str
    current_price: float
    forecast: List[ForecastDay]
    trend: str
    recommendation: str
    best_sell_date: str
    expected_peak_price: float

    class Config:
        from_attributes = True
