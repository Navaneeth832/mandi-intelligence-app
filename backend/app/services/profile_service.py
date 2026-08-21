from sqlalchemy.orm import Session, joinedload, selectinload

from app.models.user import User
from app.models.state import State
from app.models.district import District
from app.models.market import Market
from app.schemas.user import UserProfileUpdate


def get_profile(db: Session, current_user: User) -> User:
    return (
        db.query(User)
        .options(
            joinedload(User.state).selectinload(State.translations),
            joinedload(User.district).selectinload(District.translations),
            joinedload(User.preferred_market).selectinload(Market.translations),
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
    current_user.preferred_market_id = profile_data.preferred_market_id
    current_user.preferred_language = profile_data.preferred_language

    db.commit()

    return (
        db.query(User)
        .options(
            joinedload(User.state).selectinload(State.translations),
            joinedload(User.district).selectinload(District.translations),
            joinedload(User.preferred_market).selectinload(Market.translations),
        )
        .filter(User.id == current_user.id)
        .first()
    )