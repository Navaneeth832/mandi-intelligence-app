from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.state import State

router = APIRouter()


@router.get("/")
def get_states(db: Session = Depends(get_db)):
    return db.query(State).all()