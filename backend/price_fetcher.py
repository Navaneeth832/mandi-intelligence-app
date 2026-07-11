import sys
import os
import httpx
from datetime import datetime

# Solve module import paths
current_dir = os.path.dirname(os.path.abspath(__file__))
root_dir = os.path.abspath(os.path.join(current_dir, "..", ".."))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)
if root_dir not in sys.path:
    sys.path.append(root_dir)
import getId
import price_fetcher_v1
import price_fetcher_v2
import market_normalizer
import variety_normalizer
import commodity_normalizer
from price_fetcher_v1 import validate_records

try:
    from app.core.database import SessionLocal
except ImportError:
    SessionLocal = None

def parse_date(date_str):
    for fmt in ("%d/%m/%Y", "%d-%m-%Y", "%Y-%m-%d"):
        try:
            return datetime.strptime(str(date_str).strip(), fmt).date()
        except ValueError:
            pass
    raise ValueError(f"Unknown date format: {date_str}")

def resolve_group_from_commodity(commodity_name):
    try:
        import Data_mapping
        #change here
        comm_map = getattr(Data_mapping, "Commodity", getattr(Data_mapping, "commodity", {}))
        group_map = getattr(Data_mapping, "CommodityGroup", getattr(Data_mapping, "commodity_group", getattr(Data_mapping, "cmdt_group", {})))
    except ImportError:
        return "Couldn't resolve the Commodity Group"
        
    c_lower = str(commodity_name).strip().lower()
    group_id = None
    for k, v in comm_map.items():
        if k.lower() == c_lower:
            group_id = v[1]
            break
            
    if group_id is not None:
        for gk, gv in group_map.items():
            if gv == group_id:
                return gk
                
    return "Couldn't resolve the Commodity Group id"

def upsert_records_to_db(valid_records):
    if not SessionLocal:
        print("[Warning] Database SessionLocal not available. Skipping upsert.")
        return

    print(f"Upserting {len(valid_records)} records into the database...")
    db = None
    try:
        db = SessionLocal()
        from sqlalchemy.dialects.postgresql import insert
        from app.models.mandi_price import MandiPrice
        
        # Pre-load reference tables into memory to eliminate N+1 query pattern
        from app.models.commodity import Commodity
        from app.models.variety import Variety
        from app.models.grade import Grade
        from app.models.market import Market

        print("[Scheduler] Pre-loading reference tables to memory for O(1) cache lookups...")
        commodity_cache = {c.name.strip().lower(): c.id for c in db.query(Commodity.id, Commodity.name).all() if c.name}
        variety_cache = {
            (v.name.strip().lower(), v.commodity_id): v.id 
            for v in db.query(Variety.id, Variety.name, Variety.commodity_id).all() 
            if v.name and v.commodity_id
        }
        grade_cache = {
            (g.grade_name.strip().lower(), g.commodity_id): g.id 
            for g in db.query(Grade.id, Grade.grade_name, Grade.commodity_id).all() 
            if g.grade_name and g.commodity_id
        }
        market_cache = {m.name.strip().lower(): m.id for m in db.query(Market.id, Market.name).all() if m.name}
        print(f"[Scheduler] Preloaded: {len(commodity_cache)} commodities, {len(variety_cache)} varieties, {len(grade_cache)} grades, {len(market_cache)} markets.")

        upsert_count = 0
        for rec in valid_records:
            try:
                # Normalize market name using state and district as context
                original_market = rec.get("market")
                normalized_market = market_normalizer.resolve_market(
                    market_query=original_market,
                    district_query=rec.get("district"),
                    state_query=rec.get("state"),
                    fuzzy_cutoff=0.65
                )
                if normalized_market != original_market:
                    print(f"[INFO] Fuzzy matched market '{original_market}' -> '{normalized_market}' (District: {rec.get('district')}, State: {rec.get('state')})")
                    rec["market"] = normalized_market

                # Normalize commodity name
                original_commodity = rec.get("commodity")
                norm_res = commodity_normalizer.resolve_commodities(original_commodity)
                if isinstance(norm_res, list) and len(norm_res) > 0:
                    normalized_commodity = norm_res[0]["canonical_name"]
                    if normalized_commodity != original_commodity:
                        print(f"[INFO] Fuzzy matched commodity '{original_commodity}' -> '{normalized_commodity}'")
                        rec["commodity"] = normalized_commodity

                # 1. Resolve names to IDs
                comm_name_lower = rec["commodity"].strip().lower()
                if comm_name_lower in commodity_cache:
                    cmdt_id = commodity_cache[comm_name_lower]
                else:
                    cmdt_id = int(str(getId.get_commodity_id(rec["commodity"], db)).strip("[]"))
                
                # Normalize variety name using commodity_id as context
                original_variety = rec.get("variety")
                normalized_variety = variety_normalizer.resolve_variety(
                    variety_query=original_variety,
                    commodity_id=cmdt_id,
                    fuzzy_cutoff=0.65
                )
                if normalized_variety != original_variety:
                    print(f"[INFO] Fuzzy matched variety '{original_variety}' -> '{normalized_variety}' (Commodity ID: {cmdt_id})")
                    rec["variety"] = normalized_variety

                var_name_lower = rec["variety"].strip().lower()
                if (var_name_lower, cmdt_id) in variety_cache:
                    var_id = variety_cache[(var_name_lower, cmdt_id)]
                else:
                    var_id = int(str(getId.get_variety_id(rec["variety"], cmdt_id, db)).strip("[]"))

                grd_name_lower = rec["grade"].strip().lower()
                if (grd_name_lower, cmdt_id) in grade_cache:
                    grd_id = grade_cache[(grd_name_lower, cmdt_id)]
                else:
                    grd_id = int(str(getId.get_grade_id(rec["grade"], cmdt_id, db)).strip("[]"))

                mkt_name_lower = rec["market"].strip().lower()
                if mkt_name_lower in market_cache:
                    mkt_id = market_cache[mkt_name_lower]
                else:
                    mkt_id = int(str(getId.get_market_id(rec["market"], db)).strip("[]"))
                
                # 2. Parse date
                arr_date = parse_date(rec["arrival_date"])
                
                # 3. Clean and convert prices
                min_p = float(str(rec["min_price"]).replace(",", ""))
                max_p = float(str(rec["max_price"]).replace(",", ""))
                modal_p = float(str(rec["modal_price"]).replace(",", ""))
                
                # 4. Build PostgreSQL insert statement
                stmt = insert(MandiPrice).values(
                    commodity_id=cmdt_id,
                    variety_id=var_id,
                    grade_id=grd_id,
                    market_id=mkt_id,
                    arrival_date=arr_date,
                    min_price=min_p,
                    max_price=max_p,
                    modal_price=modal_p
                )
                
                # 5. On conflict do update
                stmt = stmt.on_conflict_do_update(
                    constraint="mandi_prices_unique",
                    set_={
                        "min_price": stmt.excluded.min_price,
                        "max_price": stmt.excluded.max_price,
                        "modal_price": stmt.excluded.modal_price
                    }
                )
                
                db.execute(stmt)
                upsert_count += 1
            except Exception as e:
                print(f"Failed to upsert record: {rec}. Error: {e}")
                
        db.commit()
        print(f"Successfully upserted {upsert_count} records.")
    except Exception as e:
        print(f"[Warning] Database upsert operation failed: {e}")
        if db:
            db.rollback()
    finally:
        if db:
            db.close()


def fetch_and_display_mandi_data(
    state=None,
    district=None,
    market=None,
    commodity=None,
    variety=None,
    grade=None,
    from_date= None,
    to_date= None,
    limit=10000,
    offset=0,
    group=None
):
    valid_records = []
    
    # Resolve group for v2 upfront
    if not group and commodity:
        group = resolve_group_from_commodity(commodity)
        print(f"Resolved group for '{commodity}': {group}")

    # Map parameters for Version 2
    v2_args = {
        "group": group or "Vegetables",
        "commodity": commodity or "Tomato",
    }
    if state is not None:
        v2_args["state"] = state
    if district is not None:
        v2_args["district"] = district
    if market is not None:
        v2_args["market"] = market
    if variety is not None:
        v2_args["variety"] = variety
    if grade is not None:
        v2_args["grade"] = grade
    if to_date is None:
        v2_args["to_date"] = datetime.today().strftime("%d/%m/%Y")
    if from_date is None:
        v2_args["from_date"] = datetime.today().strftime("%d/%m/%Y")
    if limit:
        v2_args["limit"] = limit


    try:
        # Attempt Version 2 (Internal Report API) first
        print("Attempting to fetch Mandi data using Version 2 (Internal Report API)...")
        valid_records = price_fetcher_v2.fetch_and_display_mandi_data_v2(**v2_args)
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        if status == 402:
            print(f"\n[Warning] Version 2 Error: 402 Payment/Access Required.")
        elif status >= 500:
            print(f"\n[Warning] Version 2 Error: {status} Server Error.")
        else:
            print(f"\n[Warning] Version 2 Error: HTTP status {status} - {e.response.text}")
        print("Switching to Version 1 (Public API)...")
    except (httpx.TimeoutException, httpx.ConnectTimeout) as e:
        print(f"\n[Warning] Version 2 Fetcher failed due to timeout: {type(e).__name__} - {e}")
        print("Switching to Version 1 (Public API)...")
    except httpx.RequestError as e:
        print(f"\n[Warning] Version 2 Error: Network connection issue: {e}")
        print("Switching to Version 1 (Public API)...")
    except Exception as e:
        print(f"\n[Warning] Version 2 Fetcher failed with unexpected error: {type(e).__name__} - {e}")
        print("Switching to Version 1 (Public API)...")

    if not valid_records:
        try:
            # Fallback to Version 1 (Public API)
            print("Attempting to fetch Mandi data using Version 1 (Public API)...")
            valid_records = price_fetcher_v1.fetch_and_display_mandi_data(
                state=state,
                district=district,
                market=market,
                commodity=commodity,
                variety=variety,
                grade=grade,
                limit=limit,
                offset=offset
            )
        except (httpx.TimeoutException, httpx.ConnectTimeout) as e:
            print(f"\n[Error] Version 1 Fetcher failed due to timeout: {type(e).__name__} - {e}")
        except httpx.HTTPStatusError as e:
            print(f"\n[Error] Version 1 Fetcher failed with HTTP status {e.response.status_code}: {e}")
        except Exception as e:
            print(f"\n[Error] Version 1 Fetcher failed with unexpected error: {type(e).__name__} - {e}")

    if valid_records:
        upsert_records_to_db(valid_records)

    return valid_records


def run_fetching_pipeline():
    if not SessionLocal:
        print("[Warning] Database SessionLocal not available. Skipping fetching pipeline.")
        return

    db = SessionLocal()
    try:
        from app.models.active_commodity import ActiveCommodity
        active_commodities = db.query(ActiveCommodity).all()
        for active in active_commodities:
            crop = active.commodity.name
            # Normalize crop name
            norm_result = commodity_normalizer.resolve_commodities(crop)
            if isinstance(norm_result, dict) and norm_result.get("error") == "commodity_not_found":
                print(f"[INFO] No commodity mapping found for '{crop}'. Skipping.")
                continue
            # Process up to top 5 canonical names (already limited by resolver)
            for canonical in norm_result[:5]:
                try:
                    fetch_and_display_mandi_data(commodity=canonical["canonical_name"])
                except Exception as e:
                    print(f"[ERROR] API call failed for '{canonical['canonical_name']}' (original query '{crop}'): {e}")
    except Exception as e:
        print(f"[ERROR] Failed to run fetching pipeline: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    run_fetching_pipeline()