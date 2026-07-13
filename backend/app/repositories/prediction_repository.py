from datetime import date
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import func
from app.models.prediction_batch import PredictionBatch
from app.models.commodity_prediction import CommodityPrediction
from app.models.commodity import Commodity
from app.models.mandi_price import MandiPrice

def get_latest_batch(db: Session) -> PredictionBatch | None:
    """Find today's latest prediction batch."""
    return (
        db.query(PredictionBatch)
        .filter(PredictionBatch.prediction_date == date.today())
        .order_by(PredictionBatch.prediction_time.desc())
        .first()
    )

def get_predictions_with_details(db: Session, batch_id: int, commodity_ids: list[int]) -> list[CommodityPrediction]:
    """
    Load every prediction row belonging to that batch for specified commodity_ids.
    Eagerly loads commodities and their translations.
    """
    return (
        db.query(CommodityPrediction)
        .options(
            selectinload(CommodityPrediction.commodity)
            .selectinload(Commodity.translations)
        )
        .filter(
            CommodityPrediction.batch_id == batch_id,
            CommodityPrediction.commodity_id.in_(commodity_ids)
        )
        .order_by(CommodityPrediction.commodity_id, CommodityPrediction.prediction_day.asc())
        .all()
    )

def get_average_modal_prices(db: Session, commodity_ids: list[int]) -> dict[int, float]:
    """
    Obtain today's current average modal_price for the specified commodities.
    If no entries exist for today, falls back to the average modal price on the latest available day.
    """
    today = date.today()
    
    # Try today's date first
    today_prices = (
        db.query(
            MandiPrice.commodity_id,
            func.avg(MandiPrice.modal_price).label("avg_modal")
        )
        .filter(
            MandiPrice.arrival_date == today,
            MandiPrice.commodity_id.in_(commodity_ids)
        )
        .group_by(MandiPrice.commodity_id)
        .all()
    )
    
    avg_price_map = {row.commodity_id: float(row.avg_modal) for row in today_prices}
    
    # Check for missing commodities and fall back to their latest available date
    missing_ids = [cid for cid in commodity_ids if cid not in avg_price_map]
    for cid in missing_ids:
        latest_date = (
            db.query(func.max(MandiPrice.arrival_date))
            .filter(MandiPrice.commodity_id == cid)
            .scalar()
        )
        if latest_date:
            latest_avg = (
                db.query(func.avg(MandiPrice.modal_price))
                .filter(
                    MandiPrice.commodity_id == cid,
                    MandiPrice.arrival_date == latest_date
                )
                .scalar()
            )
            if latest_avg is not None:
                avg_price_map[cid] = float(latest_avg)
            else:
                avg_price_map[cid] = 0.0
        else:
            avg_price_map[cid] = 0.0
            
    return avg_price_map
