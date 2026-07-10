from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, selectinload

from app.core.database import get_db
from app.models.commodity import Commodity
from app.models.mandi_price import MandiPrice
from app.schemas.commodity import CommoditySchema

router = APIRouter()


@router.get("/", response_model=list[CommoditySchema])
def get_commodities(db: Session = Depends(get_db)):
    today = date.today()
    return (
        db.query(Commodity)
        .options(selectinload(Commodity.translations))
        .join(MandiPrice, MandiPrice.commodity_id == Commodity.id)
        .filter(MandiPrice.arrival_date == today)
        .distinct()
        .order_by(Commodity.name)
        .all()
    )