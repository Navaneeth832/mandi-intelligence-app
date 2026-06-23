from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func

from app.core.database import get_db
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity
from app.models.district import District
from app.models.state import State
from datetime import date

router = APIRouter()

@router.get("/")
def get_market_directory(
    page: int = 1,
    page_size: int = 50,
    state_id: int | None = None,
    district_id: int | None = None,
    commodity_id: int | None = None,
    search: str | None = None,
    db: Session = Depends(get_db)
):
    today = date.today()

    query = (
        db.query(Market)
        .options(
            joinedload(Market.district)
            .joinedload(District.state)
        )
        .join(District)
        .join(State)
        .join(MandiPrice, MandiPrice.market_id == Market.id)
        .filter(MandiPrice.arrival_date == today)
        .distinct()
    )

    if state_id:
        query = query.filter(District.state_id == state_id)

    if district_id:
        query = query.filter(Market.district_id == district_id)

    if commodity_id:
        query = query.filter(
            MandiPrice.commodity_id == commodity_id
        )

    if search:
        search_filter = f"%{search}%"
        query = query.filter(
            (Market.name.ilike(search_filter))
            | (District.name.ilike(search_filter))
            | (State.name.ilike(search_filter))
        )

    total_records = query.count()
    total_pages = (total_records + page_size - 1) // page_size

    markets = (
        query
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )

    return {
        "page": page,
        "page_size": page_size,
        "total_records": total_records,
        "total_pages": total_pages,
        "data": [
            {
                "id": market.id,
                "name": market.name,
                "district": market.district.name,
                "state": market.district.state.name,
            }
            for market in markets
        ],
    }