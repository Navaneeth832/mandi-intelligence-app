from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.database import get_db
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity

router = APIRouter()

@router.get("/")
def get_market_directory(
    page: int = 1,
    page_size: int = 50,
    district_id: int | None = None,
    commodity_id: int | None = None,
    db: Session = Depends(get_db)
):
    query = db.query(Market)
    
    if district_id:
        query = query.filter(Market.district_id == district_id)
        
    if commodity_id:
        query = query.join(MandiPrice).filter(MandiPrice.commodity_id == commodity_id)
        
    total_records = query.count()
    total_pages = (total_records + page_size - 1) // page_size
    
    markets = query.offset((page - 1) * page_size).limit(page_size).all()
    
    result = []
    for market in markets:
        # Get unique commodities count for this market
        commodity_count = (
            db.query(func.count(func.distinct(MandiPrice.commodity_id)))
            .filter(MandiPrice.market_id == market.id)
            .scalar()
        )
        
        # Get complete commodity list for detail view
        commodities = (
            db.query(Commodity)
            .join(MandiPrice)
            .filter(MandiPrice.market_id == market.id)
            .distinct()
            .all()
        )
        
        result.append({
            "id": market.id,
            "name": market.name,
            "district": market.district.name,
            "state": market.district.state.name,
            "commodities": [c.name for c in commodities],
            "commodity_count": commodity_count or 0,
            "total_records": len(market.mandi_prices)
        })
        
    return {
        "page": page,
        "page_size": page_size,
        "total_records": total_records,
        "total_pages": total_pages,
        "data": result
    }
