from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.core.database import Base


class Market(Base):
    __tablename__ = "markets"

    id = Column(Integer, primary_key=True, index=True)

    district_id = Column(
        Integer,
        ForeignKey("districts.id"),
        nullable=False
    )

    name = Column(String, nullable=False)

    district = relationship(
        "District",
        back_populates="markets"
    )

    mandi_prices = relationship(
        "MandiPrice",
        back_populates="market"
    )