from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.commodity import Commodity
from app.models.mandi_price import MandiPrice
from app.repositories.mandi_price_repository import get_latest_arrival_date

router = APIRouter()


@router.get("/")
def get_commodities(db: Session = Depends(get_db)):
    latest_date = get_latest_arrival_date(db)
    return (
        db.query(Commodity)
        .join(MandiPrice, Commodity.id == MandiPrice.commodity_id)
        .filter(MandiPrice.arrival_date == latest_date)
        .distinct()
        .all()
    )