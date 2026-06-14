from app.schemas.price_history import (PriceHistoryResponse,)
from app.services.mandi_price_service import (fetch_price_history,)
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db

    
router = APIRouter()

@router.get(
    "/",
    response_model=list[PriceHistoryResponse],
)
def get_price_history(
    commodity: str,
    market: str,
    db: Session = Depends(get_db),
):
    return fetch_price_history(
        db,
        commodity,
        market,
    )