from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import or_, func
from datetime import date, timedelta

from app.core.database import get_db

from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity
from app.models.commodity_translation import CommodityTranslation
from app.models.state_translation import StateTranslation
from app.models.district_translation import DistrictTranslation
from app.models.market_translation import MarketTranslation
from app.models.variety import Variety
from app.models.grade import Grade
from app.models.market import Market
from app.models.district import District
from app.models.state import State

router = APIRouter()


def get_translated_name(language_code: str, entity):
    """Helper function to get translated name from any entity with translations"""
    if entity.translations:
        for translation in entity.translations:
            if translation.language_code == language_code:
                return translation.translated_name
    return None


@router.get("/")
def get_mandi_prices(
    state: str | None = None,
    district: str | None = None,
    market: str | None = None,
    commodity: str | None = None,
    variety: str | None = None,
    language: str | None = None,

    page: int = 1,
    page_size: int = 50,

    db: Session = Depends(get_db)
):

    page_size = min(page_size, 100)

    query = (
        db.query(
            State.name.label("state"),
            State.id.label("state_id"),
            District.name.label("district"),
            District.id.label("district_id"),
            Market.name.label("market"),
            Market.id.label("market_id"),
            Commodity.id.label("commodity_id"),
            Commodity.name.label("commodity"),
            Variety.name.label("variety"),
            Grade.grade_name.label("grade"),
            MandiPrice.modal_price,
            MandiPrice.min_price,
            MandiPrice.max_price,
            MandiPrice.arrival_date,
            MandiPrice.created_at,
            Commodity,
            State,
            District,
            Market
        )
        .join(Market, MandiPrice.market_id == Market.id)
        .join(District, Market.district_id == District.id)
        .join(State, District.state_id == State.id)
        .join(Commodity, MandiPrice.commodity_id == Commodity.id)
        .options(selectinload(Commodity.translations))
        .options(selectinload(State.translations))
        .options(selectinload(District.translations))
        .options(selectinload(Market.translations))
        .join(Variety, MandiPrice.variety_id == Variety.id)
        .join(Grade, MandiPrice.grade_id == Grade.id)
    )

    query = query.filter(MandiPrice.arrival_date == date.today())
    
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
        # Search in both commodity name and translations
        query = query.outerjoin(CommodityTranslation, Commodity.id == CommodityTranslation.commodity_id)
        query = query.filter(
            or_(
                Commodity.name.ilike(f"%{commodity}%"),
                CommodityTranslation.translated_name.ilike(f"%{commodity}%")
            )
        )

    if variety:
        query = query.filter(
            Variety.name.ilike(f"%{variety}%")
        )

    total_records = query.distinct().count()

    results = (
        query
        .distinct()
        .order_by(MandiPrice.created_at.desc())
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
                "state": get_translated_name(language or 'en', row.State) or row.state,
                "state_id": row.state_id,
                "district": get_translated_name(language or 'en', row.District) or row.district,
                "district_id": row.district_id,
                "market": get_translated_name(language or 'en', row.Market) or row.market,
                "market_id": row.market_id,
                "commodity": row.commodity,
                "commodity_id": row.commodity_id,
                "translated_name": get_translated_name(language or 'en', row.Commodity),
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