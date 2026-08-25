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
    commodity_image_url: str | None = None
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
    selling_window: List[str] = []
    expected_upside_pct: float = 0.0
    data_quality: str = "HIGH"
    transport_cost: float = 150.0
    market_fee: float = 45.0
    expected_profit: float = 480.0
    recommendation_reason: str = "Peak mandi prices expected in 3 days with strong market demand."
    ai_recommendation_title: str = "Optimal Profit Window"

    class Config:
        from_attributes = True

class BestMarketResponse(BaseModel):
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
    predicted_price: float
    current_price: float
    trend: str
    recommendation: str

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
