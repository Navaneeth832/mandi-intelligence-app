from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import date
from app.core.database import get_db
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.models.commodity import Commodity
from app.repositories.mandi_price_repository import get_latest_arrival_date
import logging
import requests
import urllib3
from datetime import date

router = APIRouter()


'''
    
# 🤫 Mute SSL warnings globally so they don't flood your server logs
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

logger = logging.getLogger(__name__)
router = APIRouter()

# ⚡ GLOBAL OPTIMIZATION: Set up the session ONCE outside the function
# This keeps the TCP connection pooled and WAF headers ready to fire instantly!
GOV_API_SESSION = requests.Session()
GOV_API_SESSION.headers.update({
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "application/json"
})

GOV_API_URL = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"
# PRO TIP: Move this key to your .env file in production! (e.g., os.getenv("DATA_GOV_API_KEY"))
API_KEY = "579b464db66ec23bdd000001d9a99f360c4043a457f5d16ef11380d9" 
'''
@router.get("/{market_id}/commodities")
def get_market_commodities(
    market_id: int,
    db: Session = Depends(get_db)
):
    # Get the latest arrival date to ensure we are only looking at today's commodities
    latest_date = date.today()
    
    # Query distinct commodities for the market on the latest date
    commodities = (
        db.query(Commodity.name)
        .join(MandiPrice)
        .filter(MandiPrice.market_id == market_id)
        .filter(MandiPrice.arrival_date == latest_date)
        .distinct()
        .all()
    )
    
    commodity_names = [c[0] for c in commodities]
    
    return {
        "market_id": market_id,
        "commodity_count": len(commodity_names),
        "commodities": commodity_names
    } 





@router.get("/")
def get_markets(
    district_id: int | None = None,
    db: Session = Depends(get_db)
):
    query = (
        db.query(Market)
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
    
'''
def matches_state(state_api: str, state_db: str) -> bool:
    s_api = state_api.strip().lower()
    s_db = state_db.strip().lower()
    if s_api == s_db:
        return True
    aliases = {
        "kerala": "keralam",
        "delhi": "nct of delhi",
        "pondicherry": "pondicherry",
    }
    return aliases.get(s_api, s_api) == aliases.get(s_db, s_db)


@router.get("/{market_id}/commodities")
def get_market_commodities(
    market_id: int,
    db: Session = Depends(get_db)
):
    # 1. 🕵️‍♂️ Grab the Market Name and State from the DB using the ID
    market = db.query(Market).filter(Market.id == market_id).first()
    if not market:
        raise HTTPException(status_code=404, detail="Market not found, bro! 🛑")
    
    market_name = market.name.strip()
    state_name = None
    if market.district and market.district.state:
        state_name = market.district.state.name

    # 2. 🚀 FAST PATH: Try the live Data.gov.in API first
    try:
        params = {
            "api-key": API_KEY,
            "format": "json",
            "limit": 100, 
            "filters[market]": market_name
        }
        
        # We use a short timeout (e.g., 3 seconds). If the gov server is dragging, 
        # we don't want to leave the client hanging! Fail fast, drop to fallback. ⏱️
        response = GOV_API_SESSION.get(GOV_API_URL, params=params, verify=False, timeout=3.0)
        
        # Instantly triggers the except block if status is 502, 403, etc.
        response.raise_for_status() 
        
        records = response.json().get("records", [])
        
        if records:
            # Filter in-memory to ensure matching market name and state name
            filtered_records = []
            for r in records:
                r_market = r.get("market", "").strip().lower()
                r_state = r.get("state", "")
                if r_market == market_name.lower():
                    if not state_name or matches_state(r_state, state_name):
                        filtered_records.append(r)
            
            if filtered_records:
                # Set comprehension for O(1) deduplication + sorting 🧠
                unique_commodities = sorted({r["commodity"] for r in filtered_records if "commodity" in r})
                
                return {
                    "market_id": market_id,
                    "market_name": market_name,
                    "commodity_count": len(unique_commodities),
                    "commodities": unique_commodities,
                    "source": "live_api"  # Flexing that we got fresh data 🎯
                }
            
    except Exception as e:
        # Log the failure silently without crashing the app 🤫
        logger.warning(f"Gov API failed for '{market_name}'. Falling back to local DB. Error: {e}")

    # 3. 🛡️ FALLBACK PATH: Your rock-solid original DB logic
    latest_date = date.today()
    
    commodities = (
        db.query(Commodity.name)
        .join(MandiPrice)
        .filter(MandiPrice.market_id == market_id)
        .filter(MandiPrice.arrival_date == latest_date)
        .distinct()
        .all()
    )
    
    commodity_names = [c[0] for c in commodities]
    
    return {
        "market_id": market_id,
        "market_name": market_name,
        "commodity_count": len(commodity_names),
        "commodities": commodity_names,
        "source": "database_fallback" # Letting the frontend know we used plan B 📉
    }'''