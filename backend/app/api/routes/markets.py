from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.repositories.mandi_price_repository import get_latest_arrival_date

router = APIRouter()


@router.get("/")
def get_markets(db: Session = Depends(get_db)):
    latest_date = get_latest_arrival_date(db)
    return (
        db.query(Market)
        .join(MandiPrice, Market.id == MandiPrice.market_id)
        .filter(MandiPrice.arrival_date == latest_date)
        .distinct()
        .all()
    )