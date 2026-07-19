from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, selectinload

from app.core.database import get_db
from app.models.commodity import Commodity
from app.models.mandi_price import MandiPrice
from app.schemas.commodity import CommoditySchema
from app.models.active_commodity import ActiveCommodity

from app.api.routes.mandi_prices import get_commodity_image_url

router = APIRouter()


@router.get("/", response_model=list[CommoditySchema])
def get_commodities(db: Session = Depends(get_db)):
    today = date.today()
    commodities = (
        db.query(Commodity)
        .options(selectinload(Commodity.translations))
        .join(MandiPrice, MandiPrice.commodity_id == Commodity.id)
        .filter(MandiPrice.arrival_date == today)
        .distinct()
        .order_by(Commodity.name)
        .all()
    )
    for c in commodities:
        c.commodity_image_url = get_commodity_image_url(c.id)
    return commodities

@router.get("/active", response_model=list[CommoditySchema])
def get_active_commodities(db: Session = Depends(get_db)):
    commodities = (
        db.query(Commodity)
        .options(selectinload(Commodity.translations))
        .join(ActiveCommodity,ActiveCommodity.commodity_id==Commodity.id)
        .order_by(Commodity.name)
        .all()
    )
    for c in commodities:
        c.commodity_image_url = get_commodity_image_url(c.id)
    return commodities
    
@router.get("/all", response_model=list[CommoditySchema])
def get_all_commodities(db: Session = Depends(get_db)):
    commodities = (
        db.query(Commodity)
        .options(selectinload(Commodity.translations))
        .order_by(Commodity.name)
        .all()
    )
    for c in commodities:
        c.commodity_image_url = get_commodity_image_url(c.id)
    return commodities