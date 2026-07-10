from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, selectinload

from app.core.database import get_db
from app.models.state import State
from app.models.district import District
from app.models.market import Market
from app.schemas.location import StateSchema

router = APIRouter()


def get_translated_name(language_code: str, entity):
    """Helper function to get translated name from any entity with translations"""
    if entity.translations:
        for translation in entity.translations:
            if translation.language_code == language_code:
                return translation.translated_name
    return None


@router.get("/", response_model=list[StateSchema])
def get_states(
    language: str | None = None,
    db: Session = Depends(get_db)
):
    return (
        db.query(State)
        .options(selectinload(State.translations))
        .join(District, State.id == District.state_id)
        .join(Market, District.id == Market.district_id)
        .distinct()
        .all()
    )