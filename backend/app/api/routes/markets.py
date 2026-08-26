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

router = APIRouter()


def get_translated_name(language_code: str, entity):
    """Helper function to get translated name from any entity with translations"""
    if entity.translations:
        for translation in entity.translations:
            if translation.language_code == language_code:
                return translation.translated_name
    return None


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