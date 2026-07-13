from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.prediction import ForecastResponse
from app.services.prediction_service import get_predictions_for_user

router = APIRouter()

@router.get("/", response_model=List[ForecastResponse])
def get_predictions(
    language: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Determine requested language or default to user preferred language / English
    lang = language or current_user.preferred_language or 'en'
    return get_predictions_for_user(db, current_user, lang)
