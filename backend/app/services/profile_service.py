from sqlalchemy.orm import Session, joinedload

from app.models.user import User
from app.schemas.user import UserProfileUpdate


def get_profile(db: Session, current_user: User) -> User:
    return (
        db.query(User)
        .options(
            joinedload(User.state),
            joinedload(User.district),
        )
        .filter(User.id == current_user.id)
        .first()
    )


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

    return (
        db.query(User)
        .options(
            joinedload(User.state),
            joinedload(User.district),
        )
        .filter(User.id == current_user.id)
        .first()
    )