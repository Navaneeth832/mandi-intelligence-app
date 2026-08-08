from datetime import date
from sqlalchemy.orm import Session, selectinload, joinedload
from sqlalchemy import func
from app.models.prediction_batch import PredictionBatch
from app.models.commodity_prediction import CommodityPrediction
from app.models.commodity import Commodity
from app.models.market import Market
from app.models.district import District
from app.models.state import State
from app.models.variety import Variety
from app.models.grade import Grade
from app.models.mandi_price import MandiPrice

from sqlalchemy import tuple_

def get_latest_batch(db: Session) -> PredictionBatch | None:
    """Find the most recent available prediction batch."""
    return (
        db.query(PredictionBatch)
        .order_by(
            PredictionBatch.prediction_date.desc(),
            PredictionBatch.prediction_time.desc()
        )
        .first()
    )

def get_predictions_with_details(
    db: Session,
    batch_id: int,
    commodity_ids: list[int],
    district_id: int | None = None
) -> list[CommodityPrediction]:
    """
    Load every prediction row belonging to that batch for specified commodity_ids.
    Eagerly loads commodities, markets, districts, states, varieties, grades, and translations.
    If district_id is provided, filters directly in SQL to markets in that district.
    """
    query = (
        db.query(CommodityPrediction)
        .options(
            joinedload(CommodityPrediction.commodity).selectinload(Commodity.translations),
            joinedload(CommodityPrediction.market).options(
                selectinload(Market.translations),
                joinedload(Market.district).options(
                    selectinload(District.translations),
                    joinedload(District.state).selectinload(State.translations)
                )
            ),
            joinedload(CommodityPrediction.variety),
            joinedload(CommodityPrediction.grade)
        )
        .filter(
            CommodityPrediction.batch_id == batch_id,
            CommodityPrediction.commodity_id.in_(commodity_ids)
        )
    )

    if district_id is not None:
        query = query.filter(
            CommodityPrediction.market.has(Market.district_id == district_id)
        )

    return (
        query
        .order_by(
            CommodityPrediction.commodity_id,
            CommodityPrediction.market_id,
            CommodityPrediction.variety_id,
            CommodityPrediction.grade_id,
            CommodityPrediction.prediction_day.asc()
        )
        .all()
    )

def get_latest_mandi_prices_for_combinations(db: Session, combinations: list[tuple[int, int, int, int]]) -> dict[tuple[int, int, int, int], float]:
    """
    For a list of (commodity_id, market_id, variety_id, grade_id) tuples,
    find the latest modal_price for each from mandi_prices in 1 single batched SQL query.
    """
    if not combinations:
        return {}

    price_map = {}
    keys_tuples = [
        (comm_id, mkt_id, var_id, grd_id)
        for (comm_id, mkt_id, var_id, grd_id) in combinations
    ]

    try:
        results = (
            db.query(
                MandiPrice.commodity_id,
                MandiPrice.market_id,
                MandiPrice.variety_id,
                MandiPrice.grade_id,
                MandiPrice.modal_price
            )
            .filter(
                tuple_(
                    MandiPrice.commodity_id,
                    MandiPrice.market_id,
                    MandiPrice.variety_id,
                    MandiPrice.grade_id
                ).in_(keys_tuples)
            )
            .order_by(
                MandiPrice.commodity_id,
                MandiPrice.market_id,
                MandiPrice.variety_id,
                MandiPrice.grade_id,
                MandiPrice.arrival_date.desc()
            )
            .distinct(
                MandiPrice.commodity_id,
                MandiPrice.market_id,
                MandiPrice.variety_id,
                MandiPrice.grade_id
            )
            .all()
        )
        for r in results:
            key = (r.commodity_id, r.market_id, r.variety_id, r.grade_id)
            price_map[key] = float(r.modal_price)
    except Exception:
        # Fallback to loop query if dialect does not support DISTINCT ON
        for key in combinations:
            comm_id, mkt_id, var_id, grd_id = key
            latest_price = (
                db.query(MandiPrice.modal_price)
                .filter(
                    MandiPrice.commodity_id == comm_id,
                    MandiPrice.market_id == mkt_id,
                    MandiPrice.variety_id == var_id,
                    MandiPrice.grade_id == grd_id
                )
                .order_by(MandiPrice.arrival_date.desc())
                .first()
            )
            price_map[key] = float(latest_price.modal_price) if latest_price else 0.0

    return price_map

def get_predictions_with_details_paginated(
    db: Session,
    batch_id: int,
    commodity_ids: list[int],
    page: int = 1,
    page_size: int = 15,
    commodity_id: int | None = None,
    market_id: int | None = None,
    market_ids: list[int] | None = None,
    district_id: int | None = None
) -> tuple[list[CommodityPrediction], list[tuple[int, int, int, int]], int]:
    """
    Paginate and sort distinct prediction combinations, and eagerly load detail rows.
    """
    from sqlalchemy import and_, or_
    
    # 1. Base query for combinations matching user preferences and parameters
    base_query = (
        db.query(
            CommodityPrediction.commodity_id,
            CommodityPrediction.market_id,
            CommodityPrediction.variety_id,
            CommodityPrediction.grade_id,
            Commodity.name,
            State.name,
            District.name,
            Market.name,
            Variety.name,
            Grade.grade_name
        )
        .join(Commodity, CommodityPrediction.commodity_id == Commodity.id)
        .join(Market, CommodityPrediction.market_id == Market.id)
        .join(District, Market.district_id == District.id)
        .join(State, District.state_id == State.id)
        .join(Variety, CommodityPrediction.variety_id == Variety.id)
        .join(Grade, CommodityPrediction.grade_id == Grade.id)
        .filter(
            CommodityPrediction.batch_id == batch_id,
            CommodityPrediction.commodity_id.in_(commodity_ids)
        )
    )
    
    # Apply future filters if provided
    if commodity_id is not None:
        base_query = base_query.filter(CommodityPrediction.commodity_id == commodity_id)
    if district_id is not None:
        base_query = base_query.filter(Market.district_id == district_id)
    if market_ids is not None and len(market_ids) > 0:
        base_query = base_query.filter(CommodityPrediction.market_id.in_(market_ids))
    elif market_id is not None:
        base_query = base_query.filter(CommodityPrediction.market_id == market_id)
        
    # Get distinct count of combinations
    total = base_query.distinct().count()
    
    if total == 0:
        return [], [], 0
        
    # 2. Query distinct combinations with pagination and sorting applied
    order_query = base_query.distinct().order_by(
        Commodity.name.asc(),
        State.name.asc(),
        District.name.asc(),
        Market.name.asc(),
        Variety.name.asc(),
        Grade.grade_name.asc()
    )
    
    offset = (page - 1) * page_size
    paginated_rows = order_query.offset(offset).limit(page_size).all()
    
    if not paginated_rows:
        return [], [], total
        
    paginated_combos = [
        (row.commodity_id, row.market_id, row.variety_id, row.grade_id)
        for row in paginated_rows
    ]
        
    # 3. Load detail rows for the combinations on this page
    combo_filters = [
        and_(
            CommodityPrediction.commodity_id == c_id,
            CommodityPrediction.market_id == m_id,
            CommodityPrediction.variety_id == v_id,
            CommodityPrediction.grade_id == g_id
        )
        for c_id, m_id, v_id, g_id in paginated_combos
    ]
    
    detail_rows = (
        db.query(CommodityPrediction)
        .options(
            joinedload(CommodityPrediction.commodity).selectinload(Commodity.translations),
            joinedload(CommodityPrediction.market).options(
                selectinload(Market.translations),
                joinedload(Market.district).options(
                    selectinload(District.translations),
                    joinedload(District.state).selectinload(State.translations)
                )
            ),
            joinedload(CommodityPrediction.variety),
            joinedload(CommodityPrediction.grade)
        )
        .filter(
            CommodityPrediction.batch_id == batch_id,
            or_(*combo_filters)
        )
        .order_by(
            CommodityPrediction.commodity_id,
            CommodityPrediction.market_id,
            CommodityPrediction.variety_id,
            CommodityPrediction.grade_id,
            CommodityPrediction.prediction_day.asc()
        )
        .all()
    )
    
    return detail_rows, paginated_combos, total

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
