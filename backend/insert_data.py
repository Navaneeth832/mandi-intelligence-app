from app.core.database import SessionLocal
from app.models.state import State
from app.models.district import District
from app.models.market import Market
from app.models.commodity_group import CommodityGroup
from app.models.commodity import Commodity
from app.models.variety import Variety
from app.models.grade import Grade
import sys
import importlib

session = SessionLocal()


def upsert(session, Model, record_id, **fields):
    """Insert the record if it doesn't exist; otherwise update its fields only if they have changed."""
    obj = session.get(Model, record_id)
    if obj is None:
        obj = Model(id=record_id, **fields)
        session.add(obj)
        return "inserted"
    else:
        changed = False
        for attr, val in fields.items():
            if getattr(obj, attr) != val:
                setattr(obj, attr, val)
                changed = True
        return "updated" if changed else "unchanged"


def insert_data():
    print("\nReloading Mappings...")
    if "Data_mapping" in sys.modules:
        importlib.reload(sys.modules["Data_mapping"])

    from Data_mapping import (
    State       as state_map,        # {state_name: state_id}
    District    as district_map,     # {district_id: [district_name, state_id]}
    Mandi       as mandi_map,        # {market_id: [market_name, district_id]}
    CommodityGroup as cmdt_group_map,# {group_name: group_id}
    Commodity   as commodity_map,    # {cmdt_name: [cmdt_id, cmdt_group_id]}
    Variety     as variety_map,      # {variety_id: [variety_name, cmdt_id]}
    Grade       as grade_map,        # {grade_id: [grade_name, cmdt_id]}
)
    print("\nData Mapping Loaded")
    print("\nInserting data into the database...")

    try:
        # States — {state_name: state_id}
        inserted = updated = unchanged = 0
        for name, sid in state_map.items():
            action = upsert(session, State, sid, name=name)
            if action == "inserted": inserted += 1
            elif action == "updated": updated += 1
            else: unchanged += 1
        session.commit()
        print(f"States     — inserted: {inserted}, updated: {updated}, unchanged: {unchanged}")

        # Districts — {district_id: [district_name, state_id]}
        inserted = updated = unchanged = 0
        for did, (dname, sid) in district_map.items():
            action = upsert(session, District, did, name=dname, state_id=sid)
            if action == "inserted": inserted += 1
            elif action == "updated": updated += 1
            else: unchanged += 1
        session.commit()
        print(f"Districts  — inserted: {inserted}, updated: {updated}, unchanged: {unchanged}")

        # Markets (Mandis) — {market_id: [market_name, district_id]}
        inserted = updated = unchanged = 0
        for mid, (mname, did) in mandi_map.items():
            action = upsert(session, Market, mid, name=mname, district_id=did)
            if action == "inserted": inserted += 1
            elif action == "updated": updated += 1
            else: unchanged += 1
        session.commit()
        print(f"Markets    — inserted: {inserted}, updated: {updated}, unchanged: {unchanged}")

        # Commodity Groups — {group_name: group_id}
        inserted = updated = unchanged = 0
        for gname, gid in cmdt_group_map.items():
            action = upsert(session, CommodityGroup, gid, name=gname)
            if action == "inserted": inserted += 1
            elif action == "updated": updated += 1
            else: unchanged += 1
        session.commit()
        print(f"Cmdt Groups— inserted: {inserted}, updated: {updated}, unchanged: {unchanged}")

        # Commodities — {cmdt_name: [cmdt_id, cmdt_group_id]}
        inserted = updated = unchanged = 0
        for cname, (cid, cgid) in commodity_map.items():
            action = upsert(session, Commodity, cid, name=cname, commodity_group_id=cgid)
            if action == "inserted": inserted += 1
            elif action == "updated": updated += 1
            else: unchanged += 1
        session.commit()
        print(f"Commodities— inserted: {inserted}, updated: {updated}, unchanged: {unchanged}")

        # Varieties — {variety_id: [variety_name, cmdt_id]}
        inserted = updated = unchanged = 0
        for vid, (vname, cmdt_id) in variety_map.items():
            action = upsert(session, Variety, vid, name=vname, commodity_id=cmdt_id)
            if action == "inserted": inserted += 1
            elif action == "updated": updated += 1
            else: unchanged += 1
        session.commit()
        print(f"Varieties  — inserted: {inserted}, updated: {updated}, unchanged: {unchanged}")

        # Grades — {grade_id: [grade_name, cmdt_id]}
        inserted = updated = unchanged = 0
        for gid, (gname, cmdt_id) in grade_map.items():
            action = upsert(session, Grade, gid, grade_name=gname, commodity_id=cmdt_id)
            if action == "inserted": inserted += 1
            elif action == "updated": updated += 1
            else: unchanged += 1
        session.commit()
        print(f"Grades     — inserted: {inserted}, updated: {updated}, unchanged: {unchanged}")

        print("\nAll reference data synced successfully.")

    except Exception as e:
        session.rollback()
        print(f"Error: {e}")
        raise
    finally:
        session.close()