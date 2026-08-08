from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.notification_preference import (
    NotificationPreferenceResponse,
    NotificationPreferenceUpdate,
)
from app.services.notification_preference_service import (
    NotificationPreferenceService,
)

router = APIRouter(
    prefix="/profile/notification-preferences",
    tags=["Notification Preferences"],
)


@router.get("", response_model=NotificationPreferenceResponse)
def read_notification_preferences(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Retrieve the current authenticated user's notification preferences.
    If none exist, default preferences are automatically created and returned.
    """
    return NotificationPreferenceService.get_preferences(db, current_user.id)


@router.put("", response_model=NotificationPreferenceResponse)
def edit_notification_preferences(
    preference_data: NotificationPreferenceUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Update all notification preferences for the authenticated user.
    """
    return NotificationPreferenceService.update_preferences(
        db,
        current_user.id,
        preference_data,
    )
