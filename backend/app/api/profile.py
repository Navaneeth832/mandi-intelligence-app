from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user

from app.models.user import User
from app.schemas.user import UserResponse, UserProfileUpdate

from app.services.profile_service import (
    get_profile,
    update_profile,
)

router = APIRouter(
    prefix="/profile",
    tags=["Profile"],
)


@router.get("", response_model=UserResponse)
def read_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_profile(db, current_user)

@router.put("", response_model=UserResponse)
def edit_profile(
    profile_data: UserProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return update_profile(
        db,
        current_user,
        profile_data,
    )