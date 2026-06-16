# ── Name-to-ID Resolvers with DB & Static Dictionary Fallback ────────────────

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
    if not name or str(name).startswith('['):
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
        if v[0].lower() == name_str:
            if clean_cid is None or (isinstance(v[1], list) and clean_cid in v[1]) or v[1] == clean_cid:
                return f"[{k}]"
        
    raise ValueError(f"Variety '{name}' not found.")

def get_grade_id(name, commodity_id=None, db=None):
    if not name or str(name).startswith('['):
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
        if v[0].lower() == name_str:
            if clean_cid is None or (isinstance(v[1], list) and clean_cid in v[1]) or v[1] == clean_cid:
                return f"[{k}]"
        
    raise ValueError(f"Grade '{name}' not found.")