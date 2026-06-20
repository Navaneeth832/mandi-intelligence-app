from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import date
from app.core.database import get_db
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity
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

@router.get("/{market_id}/commodities")
def get_market_commodities(
    market_id: int,
    db: Session = Depends(get_db)
):
    # Get the latest arrival date to ensure we are only looking at today's commodities
    latest_date = date.today()
    
    # Query distinct commodities for the market on the latest date
    commodities = (
        db.query(Commodity.name)
        .join(MandiPrice)
        .filter(MandiPrice.market_id == market_id)
        .filter(MandiPrice.arrival_date == latest_date)
        .distinct()
        .all()
    )
    
    commodity_names = [c[0] for c in commodities]
    
    return {
        "market_id": market_id,
        "commodity_count": len(commodity_names),
        "commodities": commodity_names
    }