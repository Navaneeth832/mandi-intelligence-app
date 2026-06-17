"""
market_normalizer.py

Normalizes a market name query to a canonical market name from Data_mapping.py.
Uses state and district context when available to narrow down candidate markets.
Fuzzy matching is performed using difflib with a default cutoff of 0.65.
"""

import sys
import os
import difflib
from typing import Optional

# Ensure the backend directory is preferred for imports
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

import Data_mapping

# Extract mappings from Data_mapping
STATE_MAP = getattr(Data_mapping, "State", {})
DISTRICT_MAP = getattr(Data_mapping, "District", {})
MANDI_MAP = getattr(Data_mapping, "Mandi", {})

# 1. Build lowercase helper maps for exact lookups
# lowercase state name -> state_id
_lower_state_to_id = {k.lower().strip(): v for k, v in STATE_MAP.items()}

# lowercase district name -> list of (district_id, state_id)
# (A district name can theoretically exist in multiple states, though rare)
_lower_district_to_info = {}
for did, (dname, sid) in DISTRICT_MAP.items():
    _lower_district_to_info.setdefault(dname.lower().strip(), []).append((did, sid))

# lowercase market name -> list of (market_name, district_id)
# (A market name can exist in multiple districts)
_lower_market_to_info = {}
for mid, (mname, did) in MANDI_MAP.items():
    _lower_market_to_info.setdefault(mname.lower().strip(), []).append((mname, did))

def resolve_market(
    market_query: str,
    district_query: Optional[str] = None,
    state_query: Optional[str] = None,
    fuzzy_cutoff: float = 0.65
) -> str:
    """
    Resolve a received market name to its canonical name in Data_mapping.py.
    
    Args:
        market_query: The market name to resolve.
        district_query: The name of the district (optional).
        state_query: The name of the state (optional).
        fuzzy_cutoff: The threshold for fuzzy matching.
        
    Returns:
        The canonical market name if found/resolved; otherwise the original market_query.
    """
    if not market_query or not market_query.strip():
        return market_query

    market_clean = market_query.strip()
    market_lower = market_clean.lower()

    # Step 1: Resolve state_id and district_id if queries are provided
    state_id = None
    if state_query:
        sq_lower = state_query.strip().lower()
        state_aliases = {
            "kerala": "keralam",
            "delhi": "nct of delhi",
            "pondicherry": "pondicherry",
        }
        sq_lower = state_aliases.get(sq_lower, sq_lower)
        state_id = _lower_state_to_id.get(sq_lower)

    district_id = None
    if district_query:
        dq_lower = district_query.strip().lower()
        district_infos = _lower_district_to_info.get(dq_lower, [])
        if district_infos:
            if state_id is not None:
                # Prioritize district in the resolved state
                for did, sid in district_infos:
                    if sid == state_id:
                        district_id = did
                        break
            if district_id is None:
                # Fallback to the first matching district
                district_id = district_infos[0][0]

    # Step 2: Try exact case-insensitive match (potentially filtered by district)
    exact_matches = _lower_market_to_info.get(market_lower, [])
    if exact_matches:
        if district_id is not None:
            for mname, did in exact_matches:
                if did == district_id:
                    return mname
        # Fallback to first exact match if district doesn't match or is not provided
        return exact_matches[0][0]

    # Step 3: Multi-tiered Fuzzy Matching

    # Tier 1: Filter candidate markets by the resolved district
    if district_id is not None:
        district_markets = {
            mname.lower().strip(): mname
            for mid, (mname, did) in MANDI_MAP.items()
            if did == district_id
        }
        if district_markets:
            matches = difflib.get_close_matches(
                market_lower,
                district_markets.keys(),
                n=1,
                cutoff=fuzzy_cutoff
            )
            if matches:
                return district_markets[matches[0]]

    # Tier 2: Filter candidate markets by the resolved state
    if state_id is not None:
        district_ids_in_state = {
            did for did, (dname, sid) in DISTRICT_MAP.items() if sid == state_id
        }
        state_markets = {
            mname.lower().strip(): mname
            for mid, (mname, did) in MANDI_MAP.items()
            if did in district_ids_in_state
        }
        if state_markets:
            matches = difflib.get_close_matches(
                market_lower,
                state_markets.keys(),
                n=1,
                cutoff=fuzzy_cutoff
            )
            if matches:
                return state_markets[matches[0]]

    # Tier 3: Global Fuzzy Match across all markets
    all_markets = {
        mname.lower().strip(): mname
        for mid, (mname, did) in MANDI_MAP.items()
    }
    matches = difflib.get_close_matches(
        market_lower,
        all_markets.keys(),
        n=1,
        cutoff=fuzzy_cutoff
    )
    if matches:
        return all_markets[matches[0]]

    # Fallback to original name
    return market_clean
