from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import date

from app.core.database import get_db

from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity
from app.models.variety import Variety
from app.models.grade import Grade
from app.models.market import Market
from app.models.district import District
from app.models.state import State

router = APIRouter()


@router.get("/")
def get_mandi_prices(
    state: str | None = None,
    district: str | None = None,
    market: str | None = None,
    commodity: str | None = None,
    variety: str | None = None,

    page: int = 1,
    page_size: int = 50,

    db: Session = Depends(get_db)
):

    page_size = min(page_size, 100)

    query = (
        db.query(
            State.name.label("state"),
            District.name.label("district"),
            Market.name.label("market"),
            Commodity.name.label("commodity"),
            Variety.name.label("variety"),
            Grade.grade_name.label("grade"),
            MandiPrice.modal_price,
            MandiPrice.min_price,
            MandiPrice.max_price,
            MandiPrice.arrival_date,
            MandiPrice.created_at
        )
        .join(Market, MandiPrice.market_id == Market.id)
        .join(District, Market.district_id == District.id)
        .join(State, District.state_id == State.id)
        .join(Commodity, MandiPrice.commodity_id == Commodity.id)
        .join(Variety, MandiPrice.variety_id == Variety.id)
        .join(Grade, MandiPrice.grade_id == Grade.id)
    )

    query = query.filter(
        MandiPrice.arrival_date == date.today()
    )

    if state:
        query = query.filter(
            State.name.ilike(f"%{state}%")
        )

    if district:
        query = query.filter(
            District.name.ilike(f"%{district}%")
        )

    if market:
        query = query.filter(
            Market.name.ilike(f"%{market}%")
        )

    if commodity:
        query = query.filter(
            Commodity.name.ilike(f"%{commodity}%")
        )

    if variety:
        query = query.filter(
            Variety.name.ilike(f"%{variety}%")
        )

    total_records = query.count()

    results = (
        query
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )

    return {
        "page": page,
        "page_size": page_size,
        "total_records": total_records,
        "total_pages":
            (total_records + page_size - 1)
            // page_size,

        "data": [
            {
                "state": row.state,
                "district": row.district,
                "market": row.market,
                "commodity": row.commodity,
                "variety": row.variety,
                "grade": row.grade,
                "modal_price": float(row.modal_price),
                "min_price": float(row.min_price), 
                "max_price": float(row.max_price),
                "arrival_date": row.arrival_date,
                "created_at": row.created_at.isoformat(),
            }
            for row in results
        ]
    }