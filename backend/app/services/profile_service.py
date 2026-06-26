from sqlalchemy.orm import Session

from app.models.user import User
from app.schemas.user import UserProfileUpdate


def get_profile(current_user: User) -> User:
    return current_user


def update_profile(
    db: Session,
    current_user: User,
    profile_data: UserProfileUpdate,
) -> User:
    current_user.name = profile_data.name
    current_user.state_id = profile_data.state_id
    current_user.district_id = profile_data.district_id
    current_user.preferred_language = profile_data.preferred_language

    db.commit()
    db.refresh(current_user)

    return current_user