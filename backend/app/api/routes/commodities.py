from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.commodity import Commodity

router = APIRouter()


@router.get("/")
def get_commodities(db: Session = Depends(get_db)):
    return db.query(Commodity).all()