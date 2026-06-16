"""
variety_normalizer.py

Normalizes a variety name query to a canonical variety name from Data_mapping.py.
Uses commodity context (commodity_id) when available to narrow down candidate varieties.
Fuzzy matching is performed using difflib with a default cutoff of 0.65.
"""

import sys
import os
import difflib
from typing import Optional, Union

# Ensure the backend directory is preferred for imports
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

try:
    import Data_mapping
    VARIETY_MAP = getattr(Data_mapping, "Variety", {})
except ImportError:
    VARIETY_MAP = {}

# Build helper maps at import time
# cmdt_id -> dict of {lowercase_variety_name: canonical_variety_name}
_cmdt_to_lower_varieties: dict[int, dict[str, str]] = {}
# global lowercase_variety_name -> canonical_variety_name
_global_lower_varieties: dict[str, str] = {}

for var_id, entry in VARIETY_MAP.items():
    if not entry or len(entry) < 2:
        continue
    vname, cmdt_id_val = entry[0], entry[1]
    if not vname:
        continue
    
    clean_vname = vname.strip()
    lower_vname = clean_vname.lower()
    
    # Track globally
    if lower_vname not in _global_lower_varieties:
        _global_lower_varieties[lower_vname] = clean_vname
        
    # Track by commodity context (cmdt_id_val could be a list or an int)
    cmdt_ids = cmdt_id_val if isinstance(cmdt_id_val, list) else [cmdt_id_val]
    for cid in cmdt_ids:
        if cid is not None:
            _cmdt_to_lower_varieties.setdefault(cid, {})[lower_vname] = clean_vname

def resolve_variety(
    variety_query: str,
    commodity_id: Optional[Union[int, str]] = None,
    fuzzy_cutoff: float = 0.65
) -> str:
    """
    Resolve a variety query to its canonical name in Data_mapping.py.
    
    Args:
        variety_query: The variety name to resolve.
        commodity_id: Optional commodity ID context (int or digit string/bracketed string).
        fuzzy_cutoff: The threshold for fuzzy matching.
        
    Returns:
        The canonical variety name if found/resolved; otherwise the original variety_query.
    """
    if not variety_query or not variety_query.strip():
        return variety_query

    variety_clean = variety_query.strip()
    variety_lower = variety_clean.lower()

    # Clean commodity_id if provided
    clean_cid = None
    if commodity_id is not None:
        cid_str = str(commodity_id).strip("[]")
        if cid_str.isdigit():
            clean_cid = int(cid_str)

    # Step 1: If commodity context is available, search locally first
    if clean_cid is not None and clean_cid in _cmdt_to_lower_varieties:
        local_map = _cmdt_to_lower_varieties[clean_cid]
        
        # 1a. Exact case-insensitive match
        if variety_lower in local_map:
            return local_map[variety_lower]
            
        # 1b. Fuzzy match within commodity context
        matches = difflib.get_close_matches(
            variety_lower,
            local_map.keys(),
            n=1,
            cutoff=fuzzy_cutoff
        )
        if matches:
            return local_map[matches[0]]

    # Step 2: Global Fallback (either no commodity context, or no match found in context)
    # 2a. Exact case-insensitive match globally
    if variety_lower in _global_lower_varieties:
        return _global_lower_varieties[variety_lower]

    # 2b. Fuzzy match globally
    matches = difflib.get_close_matches(
        variety_lower,
        _global_lower_varieties.keys(),
        n=1,
        cutoff=fuzzy_cutoff
    )
    if matches:
        return _global_lower_varieties[matches[0]]

    # Fallback to original
    return variety_clean

def resolve_varieties(
    query: str,
    commodity_id: Optional[Union[int, str]] = None,
    fuzzy_cutoff: float = 0.65,
    max_fuzzy: int = 5
) -> list[dict]:
    """
    Resolve a variety search query to multiple candidates.
    Matches first in the commodity context, then falls back globally.
    """
    if not query or not query.strip():
        return []

    variety_clean = query.strip()
    variety_lower = variety_clean.lower()

    clean_cid = None
    if commodity_id is not None:
        cid_str = str(commodity_id).strip("[]")
        if cid_str.isdigit():
            clean_cid = int(cid_str)

    candidates = {}

    # Helper function to add candidates
    def add_candidate(vname: str):
        if vname not in candidates:
            # Find variety_id and commodity_id
            for var_id, entry in VARIETY_MAP.items():
                if entry and entry[0] == vname:
                    candidates[vname] = {
                        "canonical_name": vname,
                        "variety_id": var_id,
                        "commodity_id": entry[1]
                    }
                    break

    # Contextual check
    if clean_cid is not None and clean_cid in _cmdt_to_lower_varieties:
        local_map = _cmdt_to_lower_varieties[clean_cid]
        if variety_lower in local_map:
            add_candidate(local_map[variety_lower])
        else:
            matches = difflib.get_close_matches(
                variety_lower,
                local_map.keys(),
                n=max_fuzzy,
                cutoff=fuzzy_cutoff
            )
            for m in matches:
                add_candidate(local_map[m])

    # If nothing matched in context, or no context, check globally
    if not candidates:
        if variety_lower in _global_lower_varieties:
            add_candidate(_global_lower_varieties[variety_lower])
        else:
            matches = difflib.get_close_matches(
                variety_lower,
                _global_lower_varieties.keys(),
                n=max_fuzzy,
                cutoff=fuzzy_cutoff
            )
            for m in matches:
                add_candidate(_global_lower_varieties[m])

    return list(candidates.values())

if __name__ == "__main__":
    # Test cases
    test_cases = [
        ("1121", 2),           # Basmati Paddy variety
        ("1121", 343),         # Basmati Rice variety
        ("1009 kar", 3),
        ("1009kar", 3),        # Fuzzy test
        ("Whole", 45),
        ("whole", 45),         # Case insensitive
        ("unknown_variety", 2)
    ]
    
    print("Testing variety resolver:")
    for query, cid in test_cases:
        res = resolve_variety(query, cid)
        print(f"[{query}] (cmdt_id={cid}) -> '{res}'")
