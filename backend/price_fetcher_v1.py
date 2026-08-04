#Dependency: httpx,python-dotenv,datetime

import os
import httpx
from dotenv import load_dotenv
from datetime import datetime
#from commodity_normalizer import resolve_commodities

load_dotenv()
API_KEY = os.getenv("API_KEY")
BASE_URL = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070"

def validate_records(records, target_commodity=None):
    expected_columns = [
        "state", "district", "market", "commodity", "variety", "grade",
        "arrival_date", "min_price", "max_price", "modal_price"
    ]
    
    unique_records = []
    seen = set()
    duplicates_count = 0
    
    for record in records:
        record_key = tuple(sorted((k, str(v)) for k, v in record.items()))
        if record_key in seen:
            duplicates_count += 1
            continue
        seen.add(record_key)
        unique_records.append(record)
        
    valid_records = []
    invalid_records = []
    
    for record in unique_records:
        errors = []
        
        # 1. Ensure none of the columns are null or empty
        for col in expected_columns:
            if col not in record:
                errors.append(f"Missing column '{col}'")
            else:
                val = record[col]
                if val is None:
                    errors.append(f"Column '{col}' is null")
                elif isinstance(val, str) and not val.strip():
                    errors.append(f"Column '{col}' is empty")
                    
        # 2. Ensure min, max, and modal price are numbers
        price_fields = ["min_price", "max_price", "modal_price"]
        prices = {}
        for pf in price_fields:
            if pf in record and record[pf] is not None:
                try:
                    prices[pf] = float(record[pf])
                except (ValueError, TypeError):
                    errors.append(f"Column '{pf}' value '{record[pf]}' is not a number")
                    
        # 3. If target_commodity is passed, ensure commodity is of same
        if target_commodity is not None and "commodity" in record:
            rec_commodity = record["commodity"]
            import re
            
            def are_commodities_compatible(name1, name2):
                if not name1 or not name2:
                    return False
                n1 = name1.strip().lower()
                n2 = name2.strip().lower()
                if n1 == n2:
                    return True
                n1_clean = re.sub(r'\(.*?\)', '', n1).strip()
                n2_clean = re.sub(r'\(.*?\)', '', n2).strip()
                if n1_clean == n2_clean:
                    return True
                if n1_clean in n2_clean or n2_clean in n1_clean:
                    return True
                return False

            if not rec_commodity or not are_commodities_compatible(rec_commodity, target_commodity):
                errors.append(f"Commodity mismatch: expected '{target_commodity}', got '{rec_commodity}'")
                
        # 4. Ensure min_price < max_price
        if "min_price" in prices and "max_price" in prices:
            if prices["min_price"] > prices["max_price"]:
                errors.append(f"Price relationship violated: min_price ({prices['min_price']}) is not less than max_price ({prices['max_price']})")
                
        if errors:
            invalid_records.append((record, errors))
        else:
            valid_records.append(record)
            
    return valid_records, invalid_records, duplicates_count


def fetch_and_display_mandi_data(state=None,district = None,market = None,commodity=None,variety=None,grade=None,limit=100000,offset=0):
    if not API_KEY:
        print("Error: API_KEY is not defined in the environment or .env file.")
        raise ValueError("API_KEY is not defined in the environment or .env file.")

    params = {
        "api-key": API_KEY,
        "format": "json",
        "limit": limit
    }
    if state is not None:
        params["filters[state.keyword]"] = state
    if district is not None:
        params["filters[district]"] = district
    if market is not None:
        params["filters[market]"] = market
    if commodity is not None:
        params["filters[commodity]"] = commodity
    if variety is not None:
        params["filters[variety]"] = variety
    if grade is not None:
        params["filters[grade]"] = grade

    # Custom headers to bypass security rules blocking generic python clients
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    print("Fetching Mandi data (v1)...")
    print(f"Request URL: {BASE_URL}")

    # Request data with a 30-second timeout
    with httpx.Client(timeout=30.0) as client:
        response = client.get(BASE_URL, params=params, headers=headers)
        response.raise_for_status()
        
        data = response.json()
        
        # Extract metadata
        total = data.get("total", 0)
        count = data.get("count", 0)
        records = data.get("records", [])
        updated_date = data.get("updated_date", "Unknown")            
        valid_records, invalid_records, duplicates_count = validate_records(records, target_commodity=commodity)
        
        print(f"--- API Response Metadata ---")
        print(f"Total Matching Records: {total}")
        print(f"Returned Records Count: {count}")
        print(f"Data Last Updated: {updated_date}")
        print(f"Limit used: {limit}")
        
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
        '''for i, record in enumerate(valid_records, start=1):
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
            print(f"  Modal Price:   ₹{record.get('modal_price')}")
            print("-" * 40)'''
            
        return valid_records
