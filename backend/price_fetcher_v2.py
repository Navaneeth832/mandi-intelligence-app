import sys
import os

# Solve module import paths and resolve name collisions between root and backend Data_mapping.py
current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, "..", ".."))
if root_dir not in sys.path:
    sys.path.insert(0, root_dir)
if current_dir not in sys.path:
    sys.path.append(current_dir)

import httpx
import json
from datetime import datetime
from dotenv import load_dotenv

# Try importing DB Session if available
try:
    from app.core.database import SessionLocal
    db_session_available = True
except ImportError:
    SessionLocal = None
    db_session_available = False

# Import validate_records from price_fetcher_v1 to avoid circular dependency
from price_fetcher_v1 import validate_records

# Load Data_mapping dynamically to support both root and backend casings
try:
    import Data_mapping
    COMMODITY_MAP = getattr(Data_mapping, "Commodity", getattr(Data_mapping, "commodity", {}))
    STATE_MAP = getattr(Data_mapping, "State", getattr(Data_mapping, "state", {}))
    DISTRICT_MAP = getattr(Data_mapping, "District", getattr(Data_mapping, "district", {}))
    MANDI_MAP = getattr(Data_mapping, "Mandi", getattr(Data_mapping, "mandi", {}))
    VARIETY_MAP = getattr(Data_mapping, "Variety", getattr(Data_mapping, "variety", {}))
    GRADE_MAP = getattr(Data_mapping, "Grade", getattr(Data_mapping, "grade", {}))
    GROUP_MAP = getattr(Data_mapping, "CommodityGroup", getattr(Data_mapping, "commodity_group", getattr(Data_mapping, "cmdt_group", {})))
except ImportError:
    COMMODITY_MAP = {}
    STATE_MAP = {}
    DISTRICT_MAP = {}
    MANDI_MAP = {}
    VARIETY_MAP = {}
    GRADE_MAP = {}
    GROUP_MAP = {}

# ── Name-to-ID Resolvers with DB & Static Dictionary Fallback ────────────────

def get_group_id(name, db=None):
    if not name or str(name).startswith('[') or str(name).isdigit():
        return str(name)
    name_str = str(name).strip().lower()
    
    if db:
        try:
            from app.models.commodity_group import CommodityGroup
            rec = db.query(CommodityGroup).filter(CommodityGroup.name.ilike(name_str)).first()
            if rec:
                return str(rec.id)
        except Exception:
            pass
            
    for k, v in GROUP_MAP.items():
        if k.lower() == name_str:
            return str(v)
    
    raise ValueError(f"Commodity group '{name}' not found.")

def get_commodity_id(name, db=None):
    if not name or str(name).startswith('[') or str(name).isdigit():
        return str(name)
    name_str = str(name).strip().lower()
    
    if db:
        try:
            from app.models.commodity import Commodity
            rec = db.query(Commodity).filter(Commodity.name.ilike(name_str)).first()
            if rec:
                return str(rec.id)
        except Exception:
            pass
            
    for k, v in COMMODITY_MAP.items():
        if k.lower() == name_str:
            return str(v[0])
        
    raise ValueError(f"Commodity '{name}' not found.")

def get_state_id(name, db=None):
    if not name or str(name).startswith('[') or str(name).isdigit():
        return str(name)
    name_str = str(name).strip().lower()
    
    aliases = {
        "kerala": "keralam",
        "delhi": "nct of delhi",
        "pondicherry": "pondicherry",
    }
    search_name = aliases.get(name_str, name_str)
    
    if db:
        try:
            from app.models.state import State
            rec = db.query(State).filter((State.name.ilike(search_name)) | (State.name.ilike(name_str))).first()
            if rec:
                return f"[{rec.id}]"
        except Exception:
            pass
            
    for k, v in STATE_MAP.items():
        if k.lower() in (search_name, name_str):
            return f"[{v}]"
        
    raise ValueError(f"State '{name}' not found.")

def get_district_id(name, db=None):
    if not name or str(name).startswith('[') or str(name).isdigit():
        return str(name)
    name_str = str(name).strip().lower()
    
    if db:
        try:
            from app.models.district import District
            rec = db.query(District).filter(District.name.ilike(name_str)).first()
            if rec:
                return f"[{rec.id}]"
        except Exception:
            pass
            
    for k, v in DISTRICT_MAP.items():
        if v[0].lower() == name_str:
            return f"[{k}]"
        
    raise ValueError(f"District '{name}' not found.")

def get_market_id(name, db=None):
    if not name or str(name).startswith('[') or str(name).isdigit():
        return str(name)
    name_str = str(name).strip().lower()
    
    if db:
        try:
            from app.models.market import Market
            rec = db.query(Market).filter(Market.name.ilike(name_str)).first()
            if rec:
                return f"[{rec.id}]"
        except Exception:
            pass
            
    for k, v in MANDI_MAP.items():
        if v[0].lower() == name_str:
            return f"[{k}]"
        
    raise ValueError(f"Market '{name}' not found.")

def get_variety_id(name, commodity_id=None, db=None):
    if not name or str(name).startswith('[') or str(name).isdigit():
        return str(name)
    name_str = str(name).strip().lower()
    
    if db:
        try:
            from app.models.variety import Variety
            query = db.query(Variety).filter(Variety.name.ilike(name_str))
            if commodity_id is not None:
                clean_cid = str(commodity_id).strip("[]")
                if clean_cid.isdigit():
                    query = query.filter(Variety.commodity_id == int(clean_cid))
            rec = query.first()
            if rec:
                return f"[{rec.id}]"
        except Exception:
            pass
            
    clean_cid = int(str(commodity_id).strip("[]")) if (commodity_id is not None and str(commodity_id).strip("[]").isdigit()) else None
    
    for k, v in VARIETY_MAP.items():
        if k.lower() == name_str:
            if clean_cid is None or (isinstance(v[1], list) and clean_cid in v[1]) or v[1] == clean_cid:
                return f"[{v[0]}]"
    for k, v in VARIETY_MAP.items():
        if k.lower() == name_str:
            return f"[{v[0]}]"
        
    raise ValueError(f"Variety '{name}' not found.")

def get_grade_id(name, commodity_id=None, db=None):
    if not name or str(name).startswith('[') or str(name).isdigit():
        return str(name)
    name_str = str(name).strip().lower()
    
    if db:
        try:
            from app.models.grade import Grade
            query = db.query(Grade).filter(Grade.grade_name.ilike(name_str))
            if commodity_id is not None:
                clean_cid = str(commodity_id).strip("[]")
                if clean_cid.isdigit():
                    query = query.filter(Grade.commodity_id == int(clean_cid))
            rec = query.first()
            if rec:
                return f"[{rec.id}]"
        except Exception:
            pass
            
    clean_cid = int(str(commodity_id).strip("[]")) if (commodity_id is not None and str(commodity_id).strip("[]").isdigit()) else None
    
    for k, v in GRADE_MAP.items():
        if k.lower() == name_str:
            if clean_cid is None or (isinstance(v[1], list) and clean_cid in v[1]) or v[1] == clean_cid:
                return f"[{v[0]}]"
    for k, v in GRADE_MAP.items():
        if k.lower() == name_str:
            return f"[{v[0]}]"
        
    raise ValueError(f"Grade '{name}' not found.")

# ── Core Fetching Logic using Internal API ─────────────────────────────────────

def fetch_and_display_mandi_data_v2(
    group="Vegetables",
    commodity="Tomato",
    state="[100000]",
    district="[100001]",
    market="[100002]",
    variety="[100007]",
    grade="[100003]",
    limit=10000,
    page=1
):
    internal_api = "https://api.agmarknet.gov.in/v1/daily-price-arrival/report"
    headers = {
        "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36",
        "Accept": "application/json",
    }
    
    # Establish DB session if available
    db = SessionLocal() if SessionLocal else None
    
    try:
        # Resolve all parameters to IDs
        group_id = get_group_id(group, db)
        commodity_id = get_commodity_id(commodity, db)
        state_id = get_state_id(state, db)
        district_id = get_district_id(district, db)
        market_id = get_market_id(market, db)
        variety_id = get_variety_id(variety, commodity_id, db)
        grade_id = get_grade_id(grade, commodity_id, db)
    finally:
        if db:
            db.close()

    current_day = datetime.today().strftime("%Y-%m-%d")

    payload = {
        "from_date": current_day,
        "to_date": current_day,
        "data_type": "100006",
        "group": group_id,
        "commodity": commodity_id,
        "district": district_id,
        "grade": grade_id,
        "market": market_id,
        "page": str(page),
        "limit": str(limit),
        "state": state_id,
        "variety": variety_id,
    }

    print("Fetching Mandi data (v2)...")
    print(f"Request Payload: {json.dumps(payload, indent=2)}")

    with httpx.Client(timeout=60.0) as client:
        response = client.post(internal_api, data=payload, headers=headers)
        response.raise_for_status()
        
        data = response.json()
        if not data.get("status"):
            raise ValueError(f"API Error Response: {data.get('message')}")
            
        records_wrapper = data.get("data", {}).get("records", [])
        if not records_wrapper:
            raise ValueError("No records section found in response.")
            
        pagination = records_wrapper[0].get("pagination", [{}])[0]
        total = pagination.get("total_count", 0)
        raw_records = records_wrapper[0].get("data", [])
        
        print(f"--- API Response Metadata ---")
        print(f"Total Matching Records: {total}")
        print(f"Returned Records Count: {len(raw_records)}")
        print(f"Limit used: {limit}")

        # Normalize keys and clean values for the validation layer
        normalized_records = []
        for rec in raw_records:
            min_p = str(rec.get("min_price", "")).replace(",", "")
            max_p = str(rec.get("max_price", "")).replace(",", "")
            modal_p = str(rec.get("model_price", "")).replace(",", "")
            
            normalized_rec = {
                "state": rec.get("state_name"),
                "district": rec.get("district_name"),
                "market": rec.get("market_name"),
                "commodity": rec.get("cmdt_name"),
                "variety": rec.get("variety_name"),
                "grade": rec.get("grade_name"),
                "arrival_date": rec.get("arrival_date"),
                "min_price": min_p if min_p else None,
                "max_price": max_p if max_p else None,
                "modal_price": modal_p if modal_p else None,
            }
            normalized_records.append(normalized_rec)

        valid_records, invalid_records, duplicates_count = validate_records(
            normalized_records, target_commodity=commodity if not str(commodity).isdigit() else None
        )

        if duplicates_count > 0:
            print(f"Duplicates Removed: {duplicates_count}")
        if invalid_records:
            print(f"Invalid Records Count: {len(invalid_records)}")
            for rec, errs in invalid_records:
                print(f"  Record: {rec}")
                print(f"    Validation Errors: {', '.join(errs)}")
                
        print(f"--- Retrieved Valid Mandi Price Records ---")
        if not valid_records:
            print("No valid records found matching the criteria.")
        
        for i, record in enumerate(valid_records[:5], start=1):
            print(f"Record {i}:")
            print(f"  State:         {record.get('state')}")
            print(f"  District:      {record.get('district')}")
            print(f"  Market:        {record.get('market')}")
            print(f"  Commodity:     {record.get('commodity')}")
            print(f"  Variety:       {record.get('variety')}")
            print(f"  Grade:         {record.get('grade')}")
            print(f"  Arrival Date:  {record.get('arrival_date')}")
            print(f"  Min Price:     ₹{record.get('min_price')}")
            print(f"  Max Price:     ₹{record.get('max_price')}")
            print(f"  Modal Price:   {record.get('modal_price')}")
            print("-" * 40)
            
        return valid_records

if __name__ == "__main__":
    try:
        fetch_and_display_mandi_data_v2(
            group="Vegetables",
            commodity="Tomato",
            state="Kerala",
            limit=5
        )
    except Exception as e:
        print(f"v2 error: {e}")
