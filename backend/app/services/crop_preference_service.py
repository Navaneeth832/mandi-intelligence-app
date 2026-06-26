from sqlalchemy.orm import Session

from app.models.user import User
from app.models.user_crop_preference import UserCropPreference
from app.schemas.user import CropPreferenceUpdate


def get_crop_preferences(current_user: User):
    return [
        {
            "commodity_id": pref.commodity_id,
            "commodity_name": pref.commodity.name,
        }
        for pref in current_user.crop_preferences
    ]


def update_crop_preferences(
    db: Session,
    current_user: User,
    preference_data: CropPreferenceUpdate,
):
    # Remove old preferences
    db.query(UserCropPreference).filter(
        UserCropPreference.user_id == current_user.id
    ).delete()

    # Add new preferences
    for commodity_id in preference_data.commodity_ids:
        db.add(
            UserCropPreference(
                user_id=current_user.id,
                commodity_id=commodity_id,
            )
        )

    db.commit()
    db.refresh(current_user)

    return [
    {
        "commodity_id": pref.commodity_id,
        "commodity_name": pref.commodity.name,
    }
    for pref in current_user.crop_preferences
    ]