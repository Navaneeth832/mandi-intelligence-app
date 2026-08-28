from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import func
from datetime import date
from app.core.database import get_db
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity
from app.repositories.mandi_price_repository import get_latest_arrival_date
from app.schemas.location import MarketSchema
import logging
import requests
import urllib3
from datetime import date
from pydantic import BaseModel

router = APIRouter()

class ClosestMarketResponse(BaseModel):
    market_id: int
    district_id: int


class MarketComparisonItem(BaseModel):
    market_id: int
    market_name: str
    district_name: str
    state_name: str
    latitude: float | None = None
    longitude: float | None = None
    distance_km: float
    selling_price: float         # Price per quintal (₹/qtl)
    transport_cost: float        # Transport cost per quintal based on rate & distance
    mandi_commission: float      # Mandi fee/commission per quintal
    net_profit: float            # Net profit per quintal = selling_price - (transport_cost + mandi_commission)
    total_net_profit: float      # Total profit for specified quantity
    is_best_value: bool = False  # True for the mandi yielding highest net profit


class MarketComparisonResponse(BaseModel):
    user_latitude: float
    user_longitude: float
    commodity_id: int | None
    quantity_quintals: float
    transport_rate_per_km: float
    markets: list[MarketComparisonItem]


def get_translated_name(language_code: str, entity):
    """Helper function to get translated name from any entity with translations"""
    if entity.translations:
        for translation in entity.translations:
            if translation.language_code == language_code:
                return translation.translated_name
    return None


@router.get("/compare-mock", response_model=MarketComparisonResponse)
def get_market_comparison_mock(
    lat: float = 9.5916,
    lng: float = 76.5222,
    commodity_id: int | None = None,
    transport_rate_per_km: float = 2.5,
    quantity: float = 10.0,
    db: Session = Depends(get_db)
):
    """
    MOCK ENDPOINT: Get financial comparison across nearby mandis.
    -----------------------------------------------------------------------
    NOTE:
    To replace this mock endpoint with actual database calculations:
    1. Query top 10 closest markets using PostGIS:
       `user_point = cast(func.ST_SetSRID(func.ST_MakePoint(lng, lat), 4326), Geography)`
       `distance_km = func.ST_Distance(Market.location, user_point) / 1000.0`
    2. Join `MandiPrice` to fetch the latest `modal_price` for `commodity_id`.
    3. Calculate:
       - `transport_cost = distance_km * transport_rate_per_km`
       - `mandi_commission = selling_price * 0.01` (1% fee)
       - `net_profit = selling_price - transport_cost - mandi_commission`
       - `total_net_profit = net_profit * quantity`
    4. Mark the market with the highest `net_profit` as `is_best_value = True`.
    -----------------------------------------------------------------------
    """
    # Realistic mock dataset around requested coordinates
    mock_mandis = [
        {
            "market_id": 101,
            "market_name": "Kottayam Mandi",
            "district_name": "Kottayam",
            "state_name": "Kerala",
            "latitude": 9.5916,
            "longitude": 76.5222,
            "distance_km": 6.4,
            "selling_price": 2450.0,
        },
        {
            "market_id": 102,
            "market_name": "Ettumanoor Mandi",
            "district_name": "Kottayam",
            "state_name": "Kerala",
            "latitude": 9.6685,
            "longitude": 76.5623,
            "distance_km": 11.2,
            "selling_price": 2480.0,
        },
        {
            "market_id": 103,
            "market_name": "Changanassery Mandi",
            "district_name": "Kottayam",
            "state_name": "Kerala",
            "latitude": 9.4473,
            "longitude": 76.5370,
            "distance_km": 17.5,
            "selling_price": 2520.0,
        },
        {
            "market_id": 104,
            "market_name": "Pala Mandi",
            "district_name": "Kottayam",
            "state_name": "Kerala",
            "latitude": 9.7107,
            "longitude": 76.6841,
            "distance_km": 26.8,
            "selling_price": 2560.0,
        },
        {
            "market_id": 105,
            "market_name": "Thiruvalla Mandi",
            "district_name": "Pathanamthitta",
            "state_name": "Kerala",
            "latitude": 9.3834,
            "longitude": 76.5741,
            "distance_km": 24.1,
            "selling_price": 2410.0,
        },
    ]

    items = []
    for m in mock_mandis:
        dist = m["distance_km"]
        price = m["selling_price"]
        t_cost = round(dist * transport_rate_per_km, 2)
        comm = round(price * 0.01, 2)  # 1% mandi commission
        net_p = round(price - t_cost - comm, 2)
        tot_p = round(net_p * quantity, 2)

        items.append(MarketComparisonItem(
            market_id=m["market_id"],
            market_name=m["market_name"],
            district_name=m["district_name"],
            state_name=m["state_name"],
            latitude=m["latitude"],
            longitude=m["longitude"],
            distance_km=dist,
            selling_price=price,
            transport_cost=t_cost,
            mandi_commission=comm,
            net_profit=net_p,
            total_net_profit=tot_p,
            is_best_value=False
        ))

    # Determine Best Value mandi (highest net profit per quintal)
    if items:
        max_item = max(items, key=lambda x: x.net_profit)
        max_item.is_best_value = True

    return MarketComparisonResponse(
        user_latitude=lat,
        user_longitude=lng,
        commodity_id=commodity_id,
        quantity_quintals=quantity,
        transport_rate_per_km=transport_rate_per_km,
        markets=items
    )


@router.get("/closest", response_model=list[ClosestMarketResponse])
def get_closest_markets(
    lat: float,
    lng: float,
    db: Session = Depends(get_db)
):
    """
    Get the top 10 closest markets to a given latitude and longitude.
    """
    query = (
        db.query(Market.id, Market.district_id)
        .filter(Market.location.isnot(None))
        .order_by(
            Market.location.op('<->')(func.ST_SetSRID(func.ST_MakePoint(lng, lat), 4326))
        )
        .limit(10)
    )
    results = query.all()
    return [{"market_id": r.id, "district_id": r.district_id} for r in results]



@router.get("/{market_id}/commodities")
def get_market_commodities(
    market_id: int,
    language: str | None = None,
    db: Session = Depends(get_db)
):
    # Get the latest arrival date to ensure we are only looking at today's commodities
    latest_date = date.today()
    
    # Query distinct commodities for the market on the latest date
    commodities = (
        db.query(Commodity)
        .options(selectinload(Commodity.translations))
        .join(MandiPrice)
        .filter(MandiPrice.market_id == market_id)
        .filter(MandiPrice.arrival_date == latest_date)
        .distinct()
        .all()
    )
    
    commodity_names = [
        get_translated_name(language or 'en', c) or c.name
        for c in commodities
    ]
    
    return {
        "market_id": market_id,
        "commodity_count": len(commodity_names),
        "commodities": commodity_names
    } 


@router.get("/all", response_model=list[MarketSchema])
def get_all_markets(
    district_id: int | None = None,
    language: str | None = None,
    db: Session = Depends(get_db)
):
    query = (
        db.query(Market)
        .options(selectinload(Market.translations))
    )
    if district_id:
        query = query.filter(
            Market.district_id == district_id
        )

    return (
        query
        .order_by(Market.name)
        .all()
    )


@router.get("/", response_model=list[MarketSchema])
def get_markets(
    district_id: int | None = None,
    language: str | None = None,
    db: Session = Depends(get_db)
):
    query = (
        db.query(Market)
        .options(selectinload(Market.translations))
    )
    today = date.today()
    if district_id:
        query = query.filter(
            Market.district_id == district_id
        )

    return (
        query
        .distinct()
        .join(MandiPrice)
        .filter(MandiPrice.market_id == Market.id)
        .filter(MandiPrice.arrival_date == today)
        .order_by(Market.name)
        .all()
    )