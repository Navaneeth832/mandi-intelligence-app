from typing import List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.prediction import PaginatedForecastResponse, BestMarketResponse
from app.services.prediction_service import get_predictions_for_user, get_best_markets_for_commodity

router = APIRouter()

@router.get("/", response_model=PaginatedForecastResponse)
def get_predictions(
    page: int = 1,
    page_size: int = 15,
    language: str | None = None,
    commodity_id: int | None = None,
    market_id: int | None = None,
    commodity_ids: List[int] | None = Query(None),
    market_ids: List[int] | None = Query(None),
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
        market_id=market_id,
        commodity_ids=commodity_ids,
        market_ids=market_ids
    )

@router.get("/best-markets", response_model=List[BestMarketResponse])
def get_best_markets(
    commodity_id: int,
    language: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    lang = language or current_user.preferred_language or 'en'
    return get_best_markets_for_commodity(
        db,
        current_user,
        commodity_id=commodity_id,
        language=lang
    )
