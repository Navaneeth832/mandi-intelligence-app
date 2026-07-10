# routers/districts.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, selectinload

from app.core.database import get_db
from app.models.district import District

from app.models.state import State
from app.schemas.location import DistrictSchema

router = APIRouter()


def get_translated_name(language_code: str, entity):
    """Helper function to get translated name from any entity with translations"""
    if entity.translations:
        for translation in entity.translations:
            if translation.language_code == language_code:
                return translation.translated_name
    return None


@router.get("/", response_model=list[DistrictSchema])
def get_districts(
    state: str | None = None,
    state_id: int | None = None,
    language: str | None = None,
    db: Session = Depends(get_db)
):
    query = (
        db.query(District)
        .options(selectinload(District.translations))
        .join(State)
    )

    if state:
        query = query.filter(
            State.name == state
        )
    
    if state_id:
        query = query.filter(
            District.state_id == state_id
        )

    return (
        query
        .order_by(District.name)
        .all()
    )