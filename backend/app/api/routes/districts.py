# routers/districts.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.district import District

from app.models.state import State

router = APIRouter()


@router.get("/")
def get_districts(
    state: str | None = None,
    db: Session = Depends(get_db)
):
    query = (
        db.query(District)
        .join(State)
    )

    if state:
        query = query.filter(
            State.name == state
        )

    return (
        query
        .order_by(District.name)
        .all()
    )