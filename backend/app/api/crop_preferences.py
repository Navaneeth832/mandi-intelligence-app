from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user

from app.models.user import User
from app.schemas.user import (
    CropPreferenceUpdate,
    CropPreferenceResponse,
)

from app.services.crop_preference_service import (
    get_crop_preferences,
    update_crop_preferences,
)

router = APIRouter(
    prefix="/profile/preferences",
    tags=["Crop Preferences"],
)


@router.get("", response_model=List[CropPreferenceResponse])
def read_crop_preferences(
    current_user: User = Depends(get_current_user),
):
    return get_crop_preferences(current_user)


@router.put("", response_model=List[CropPreferenceResponse])
def edit_crop_preferences(
    preference_data: CropPreferenceUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return update_crop_preferences(
        db,
        current_user,
        preference_data,
    )