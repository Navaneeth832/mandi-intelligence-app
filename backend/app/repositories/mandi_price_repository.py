from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity
from app.models.market import Market
from app.models.variety import Variety

def get_latest_arrival_date(db: Session):
    return db.query(func.max(MandiPrice.arrival_date)).scalar()

def get_price_history(
    db: Session,
    commodity_name: str,
    market_name: str,
    variety_name: str,
):
    return (
        db.query(
            MandiPrice.arrival_date,
            MandiPrice.modal_price,
        )
        .join(
            Commodity,
            Commodity.id == MandiPrice.commodity_id,
        )
        .join(
            Market,
            Market.id == MandiPrice.market_id,
        )
        .join(
            Variety,
            Variety.id == MandiPrice.variety_id,
        )
        .filter(
            Commodity.name == commodity_name,
            Market.name == market_name,
            Variety.name == variety_name,
        )
        .order_by(
            MandiPrice.arrival_date.desc()
        )
        .limit(7)
        .all()
    )