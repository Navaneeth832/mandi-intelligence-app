from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.market import Market

router = APIRouter()


@router.get("/")
def get_markets(db: Session = Depends(get_db)):
    return db.query(Market).all()