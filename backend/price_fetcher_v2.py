import sys
import os

# Solve module import paths and resolve name collisions between root and backend Data_mapping.py
current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, "..", ".."))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)
if root_dir not in sys.path:
    sys.path.append(root_dir)
import getId
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

# ── Core Fetching Logic using Internal API ─────────────────────────────────────

def fetch_and_display_mandi_data_v2(
    group,
    commodity,
    state="[100000]",
    district="[100001]",
    market="[100002]",
    variety="[100007]",
    grade="[100003]",
    from_date= datetime.today().strftime("%Y-%m-%d"),
    to_date = datetime.today().strftime("%Y-%m-%d"),
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
        group_id = getId.get_group_id(group, db)
        commodity_id = getId.get_commodity_id(commodity, db)
        state_id = getId.get_state_id(state, db)
        district_id = getId.get_district_id(district, db)
        market_id = getId.get_market_id(market, db)
        variety_id = getId.get_variety_id(variety, commodity_id, db)
        grade_id = getId.get_grade_id(grade, commodity_id, db)
    finally:
        if db:
            db.close()

    # Convert from_date and to_date from %d/%m/%Y to %Y-%m-%d if they contain slashes
    from_date_formatted = from_date
    if from_date and "/" in from_date:
        try:
            from_date_formatted = datetime.strptime(from_date, "%d/%m/%Y").strftime("%Y-%m-%d")
        except ValueError:
            pass

    to_date_formatted = to_date
    if to_date and "/" in to_date:
        try:
            to_date_formatted = datetime.strptime(to_date, "%d/%m/%Y").strftime("%Y-%m-%d")
        except ValueError:
            pass

    payload = {
        "from_date": from_date_formatted,
        "to_date": to_date_formatted,
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
        
        '''for i, record in enumerate(valid_records[:5], start=1):
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
            print("-" * 40)'''
            
        return valid_records
