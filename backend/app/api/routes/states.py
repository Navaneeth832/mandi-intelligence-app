from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.state import State
from app.models.district import District
from app.models.market import Market
from app.models.mandi_price import MandiPrice
from app.repositories.mandi_price_repository import get_latest_arrival_date

router = APIRouter()


@router.get("/")
def get_states(db: Session = Depends(get_db)):
    return (
        db.query(State)
        .join(District, State.id == District.state_id)
        .join(Market, District.id == Market.district_id)
        .distinct()
        .all()
    )