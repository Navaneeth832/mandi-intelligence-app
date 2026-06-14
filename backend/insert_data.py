from app.core.database import SessionLocal
from app.models.state import State
from app.models.district import District
from app.models.market import Market
from app.models.commodity_group import CommodityGroup
from app.models.commodity import Commodity
from app.models.variety import Variety
from app.models.grade import Grade

from Data_mapping import (
    State       as state_map,        # {state_name: state_id}
    District    as district_map,     # {district_id: [district_name, state_id]}
    Mandi       as mandi_map,        # {market_id: [market_name, district_id]}
    CommodityGroup as cmdt_group_map,# {group_name: group_id}
    Commodity   as commodity_map,    # {cmdt_name: [cmdt_id, cmdt_group_id]}
    Variety     as variety_map,      # {variety_name: [variety_id, [cmdt_ids]]}
    Grade       as grade_map,        # {grade_name: [grade_id, [cmdt_ids]]}
)

session = SessionLocal()

try:
    # States — {state_name: state_id}
    for name, sid in state_map.items():
        session.add(State(id=sid, name=name))
    session.commit()
    print(f"Inserted {len(state_map)} states.")

    # Districts — {district_id: [district_name, state_id]}
    for did, (dname, sid) in district_map.items():
        session.add(District(id=did, name=dname, state_id=sid))
    session.commit()
    print(f"Inserted {len(district_map)} districts.")

    # Markets (Mandis) — {market_id: [market_name, district_id]}
    for mid, (mname, did) in mandi_map.items():
        session.add(Market(id=mid, name=mname, district_id=did))
    session.commit()
    print(f"Inserted {len(mandi_map)} markets.")

    # Commodity Groups — {group_name: group_id}
    for gname, gid in cmdt_group_map.items():
        session.add(CommodityGroup(id=gid, name=gname))
    session.commit()
    print(f"Inserted {len(cmdt_group_map)} commodity groups.")

    # Commodities — {cmdt_name: [cmdt_id, cmdt_group_id]}
    for cname, (cid, cgid) in commodity_map.items():
        session.add(Commodity(id=cid, name=cname, commodity_group_id=cgid))
    session.commit()
    print(f"Inserted {len(commodity_map)} commodities.")

    # Varieties — {variety_name: [variety_id, cmdt_ids]}
    for vid, (vname, cmdt_id) in variety_map.items():
        session.add(Variety(id=vid, name=vname, commodity_id=cmdt_id))
    session.commit()
    print(f"Inserted {len(variety_map)} varieties.")

    # Grades — {grade_name: [grade_id, cmdt_id]}
    for gid, (gname, cmdt_id) in grade_map.items():
        session.add(Grade(id=gid, grade_name=gname, commodity_id=cmdt_id))
    session.commit()
    print(f"Inserted {len(grade_map)} grades.")

    print("\nAll data inserted successfully.")

except Exception as e:
    session.rollback()
    print(f"Error: {e}")
    raise
finally:
    session.close()