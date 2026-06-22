from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.commodity import Commodity
from app.models.mandi_price import MandiPrice

router = APIRouter()


@router.get("/")
def get_commodities(db: Session = Depends(get_db)):
    today = date.today()
    return (
        db.query(Commodity)
        .distinct()
        .all()
    )