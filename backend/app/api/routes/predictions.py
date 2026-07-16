from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.prediction import PaginatedForecastResponse
from app.services.prediction_service import get_predictions_for_user

router = APIRouter()

@router.get("/", response_model=PaginatedForecastResponse)
def get_predictions(
    page: int = 1,
    page_size: int = 15,
    language: str | None = None,
    commodity_id: int | None = None,
    market_id: int | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Determine requested language or default to user preferred language / English
    lang = language or current_user.preferred_language or 'en'
    return get_predictions_for_user(
        db,
        current_user,
        lang,
        page=page,
        page_size=page_size,
        commodity_id=commodity_id,
        market_id=market_id
    )
