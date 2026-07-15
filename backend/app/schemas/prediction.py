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
    market_id: int
    market_name: str
    district_id: int
    district_name: str
    state_id: int
    state_name: str
    variety_id: int
    variety_name: str
    grade_id: int
    grade_name: str
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

class PaginatedForecastResponse(BaseModel):
    page: int
    page_size: int
    total: int
    has_next: bool
    predictions: List[ForecastResponse]

    class Config:
        from_attributes = True
