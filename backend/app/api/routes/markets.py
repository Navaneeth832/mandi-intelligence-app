from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.repositories.mandi_price_repository import get_latest_arrival_date

router = APIRouter()


@router.get("/")
def get_markets(
    district_id: int | None = None,
    db: Session = Depends(get_db)
):
    query = (
        db.query(Market)
        .join(MandiPrice, Market.id == MandiPrice.market_id)
    )

    if district_id:
        query = query.filter(
            Market.district_id == district_id
        )

    return (
        query
        .distinct()
        .order_by(Market.name)
        .all()
    )