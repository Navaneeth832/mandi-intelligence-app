from typing import Optional
from datetime import datetime
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.alert import PaginatedAlertsResponse, AlertType
from app.services.alert_service import AlertService

router = APIRouter()

ALLOWED_ALERT_TYPES = {
    AlertType.BETTER_MARKET.value,
    AlertType.PRICE_INCREASE.value,
    AlertType.PRICE_DROP.value,
    AlertType.AI_RECOMMENDATION.value,
    "ALL",
}

def _validate_alert_type(type_param: Optional[str]) -> Optional[str]:
    if not type_param:
        return None
    normalized = type_param.strip().upper()
    if normalized not in ALLOWED_ALERT_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid alert type '{type_param}'. Allowed values: BETTER_MARKET, PRICE_INCREASE, PRICE_DROP, AI_RECOMMENDATION",
        )
    return normalized

def _parse_date_bound(date_str: Optional[str], is_end_of_day: bool = False) -> Optional[datetime]:
    if not date_str or not date_str.strip():
        return None
    s = date_str.strip()
    try:
        if len(s) == 10: # YYYY-MM-DD
            dt = datetime.strptime(s, "%Y-%m-%d")
            if is_end_of_day:
                return dt.replace(hour=23, minute=59, second=59, microsecond=999999)
            return dt
        return datetime.fromisoformat(s)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid date format for '{date_str}'. Expected format: YYYY-MM-DD",
        )

@router.get("", response_model=PaginatedAlertsResponse)
@router.get("/", response_model=PaginatedAlertsResponse, include_in_schema=False)
def get_alerts(
    type: Optional[str] = Query(None, description="Alert type filter: BETTER_MARKET, PRICE_INCREASE, PRICE_DROP, AI_RECOMMENDATION"),
    page: int = Query(1, ge=1, description="Page number starting at 1"),
    page_size: int = Query(20, ge=1, description="Items per page (max 50)"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Return current/recent actionable alerts applicable to the authenticated user.
    """
    if page_size > 50:
        raise HTTPException(status_code=400, detail="page_size cannot exceed 50")

    validated_type = _validate_alert_type(type)

    return AlertService.get_alerts(
        db=db,
        user=current_user,
        type=validated_type,
        page=page,
        page_size=page_size,
    )

@router.get("/history", response_model=PaginatedAlertsResponse)
def get_alert_history(
    type: Optional[str] = Query(None, description="Alert type filter: BETTER_MARKET, PRICE_INCREASE, PRICE_DROP, AI_RECOMMENDATION"),
    search: Optional[str] = Query(None, description="Search query matching title, message, commodity, or market"),
    date_from: Optional[str] = Query(None, description="Filter alerts created on or after date (YYYY-MM-DD)"),
    date_to: Optional[str] = Query(None, description="Filter alerts created on or before date (YYYY-MM-DD)"),
    page: int = Query(1, ge=1, description="Page number starting at 1"),
    page_size: int = Query(20, ge=1, description="Items per page (max 50)"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Return historical alerts for the authenticated user supporting filtering, search, date bounds, and pagination.
    """
    if page_size > 50:
        raise HTTPException(status_code=400, detail="page_size cannot exceed 50")

    validated_type = _validate_alert_type(type)
    from_dt = _parse_date_bound(date_from, is_end_of_day=False)
    to_dt = _parse_date_bound(date_to, is_end_of_day=True)

    return AlertService.get_alert_history(
        db=db,
        user=current_user,
        type=validated_type,
        search=search,
        date_from=from_dt,
        date_to=to_dt,
        page=page,
        page_size=page_size,
    )
