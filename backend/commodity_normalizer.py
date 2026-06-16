"""
commodity_normalizer.py

Resolves a user's commodity search query to a list of canonical commodities.
Each result contains the canonical name, cmdt_id, group_id, and valid varieties/grades.

Source of truth: Data_mapping.py  (Commodity, Variety, Grade dicts)
Alias source:    commodity_aliases.py

Resolution order:
  1. Alias match        (commodity_aliases.py → COMMODITY_ALIASES)
  2. Exact CI match     (Data_mapping.Commodity keys, case-insensitive)
  3. Fuzzy match        (difflib, cutoff=0.65)

Variety/Grade lookup:
  - Built once at import from Data_mapping.Variety / Data_mapping.Grade
  - Keyed by cmdt_id → fetched on-demand per resolved commodity
  - No DB connections, no data.json required

Errors:
  - MappingNotFoundError  → raised at import if Commodity dict is empty
  - commodity_not_found   → returned as dict if query resolves to nothing
"""

import difflib
from typing import Union

from Data_mapping import Commodity as COMMODITY_MAP
from Data_mapping import Variety as VARIETY_MAP
from Data_mapping import Grade as GRADE_MAP
from commodity_aliases import COMMODITY_ALIASES


# ---------------------------------------------------------------------------
# Custom exception
# ---------------------------------------------------------------------------

class MappingNotFoundError(Exception):
    """Raised when the Commodity mapping in Data_mapping.py is empty."""


# ---------------------------------------------------------------------------
# Guard: fail fast if mapping is empty
# ---------------------------------------------------------------------------

if not COMMODITY_MAP:
    raise MappingNotFoundError(
        "Data_mapping.Commodity is empty. "
        "Ensure Data_mapping.py is correctly populated before using this module."
    )


# ---------------------------------------------------------------------------
# Build lookup structures at import time
# ---------------------------------------------------------------------------

# lowercase canonical key → original canonical key (for case-insensitive exact match)
_lower_to_canonical: dict[str, str] = {k.lower(): k for k in COMMODITY_MAP}

# cmdt_id → list of variety names  (built once from VARIETY_MAP)
# VARIETY_MAP structure: {variety_id: [variety_name, cmdt_id]}
_cmdt_id_to_varieties: dict[int, list[str]] = {}
for _entry in VARIETY_MAP.values():
    _variety_name, _cmdt_id = _entry[0], _entry[1]
    if _variety_name:
        _cmdt_id_to_varieties.setdefault(_cmdt_id, []).append(_variety_name)

# cmdt_id → list of grade names  (built once from GRADE_MAP)
# GRADE_MAP structure: {grade_id: [grade_name, cmdt_id]}
_cmdt_id_to_grades: dict[int, list[str]] = {}
for _entry in GRADE_MAP.values():
    _grade_name, _cmdt_id = _entry[0], _entry[1]
    if _grade_name:
        _cmdt_id_to_grades.setdefault(_cmdt_id, []).append(_grade_name)


# ---------------------------------------------------------------------------
# Core helpers
# ---------------------------------------------------------------------------

def _build_result(canonical_name: str) -> dict:
    """Build a result dict for a resolved canonical commodity name."""
    cmdt_id, group_id = COMMODITY_MAP[canonical_name]
    return {
        "canonical_name": canonical_name,
        "cmdt_id": cmdt_id,
        "group_id": group_id,
        "varieties": _cmdt_id_to_varieties.get(cmdt_id, []),
        "grades": _cmdt_id_to_grades.get(cmdt_id, []),
    }


def _not_found(query: str) -> dict:
    return {"error": "commodity_not_found", "query": query}


# ---------------------------------------------------------------------------
# Public resolver
# ---------------------------------------------------------------------------

def resolve_commodities(
    query: str,
    fuzzy_cutoff: float = 0.65,
    max_fuzzy: int = 5,
) -> Union[list[dict], dict]:
    """
    Resolve a user query to one or more canonical commodity results.

    Args:
        query:        User search string (any case, with/without special chars).
        fuzzy_cutoff: Similarity cutoff for fuzzy matching (0–1, higher = stricter).
        max_fuzzy:    Max number of fuzzy candidates to return.

    Returns:
        List of dicts on success, each with keys:
            canonical_name, cmdt_id, group_id, varieties, grades

        Dict on failure:
            {"error": "commodity_not_found", "query": "<query>"}
    """
    if not query or not query.strip():
        return _not_found(query)

    normalized = query.strip().lower()

    # 1. Alias match -----------------------------------------------------------
    if normalized in COMMODITY_ALIASES:
        canonical_names = COMMODITY_ALIASES[normalized]
        results = [
            _build_result(name)
            for name in canonical_names
            if name in COMMODITY_MAP
        ]
        if results:
            return results

    # 2. Exact case-insensitive match ------------------------------------------
    if normalized in _lower_to_canonical:
        return [_build_result(_lower_to_canonical[normalized])]

    # 3. Fuzzy match -----------------------------------------------------------
    matches = difflib.get_close_matches(
        normalized,
        _lower_to_canonical.keys(),
        n=max_fuzzy,
        cutoff=fuzzy_cutoff,
    )
    if matches:
        return [_build_result(_lower_to_canonical[m]) for m in matches]

    return _not_found(query)


# ---------------------------------------------------------------------------
# Pretty-print helper
# ---------------------------------------------------------------------------

def print_resolve(query: str) -> None:
    """Pretty-print resolution results for a query. Useful for quick testing."""
    result = resolve_commodities(query)

    if isinstance(result, dict):  # error case
        print(f"['{query}'] → {result['error']}")
        return

    print(f"['{query}'] → {len(result)} commodity(ies) matched:")
    '''for r in result:
        varieties_preview = r["varieties"][:5]
        varieties_suffix = "..." if len(r["varieties"]) > 5 else ""
        grades_preview = r["grades"][:5]
        grades_suffix = "..." if len(r["grades"]) > 5 else ""
        print(f"  ├─ {r['canonical_name']} (cmdt_id={r['cmdt_id']}, group={r['group_id']})")
        print(f"  │   Varieties ({len(r['varieties'])}): {varieties_preview}{varieties_suffix}")
        print(f"  │   Grades    ({len(r['grades'])}): {grades_preview}{grades_suffix}")'''
    return result


# ---------------------------------------------------------------------------
# Quick test when run directly
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    test_queries = [
        "paddy rice",
        "Paddy(Common)",
        "paddy",
        "bhindi",
        "arhar dal",
        "moong",
        "wheat",
        "tomato",
        "hari mirch",
        "xyz unknown crop",
        "",                   # empty input
    ]
    for q in test_queries:
        print_resolve(q)
        print()
