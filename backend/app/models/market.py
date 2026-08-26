from sqlalchemy import Column, Integer, String, ForeignKey, Float
from sqlalchemy.orm import relationship
from geoalchemy2 import Geography

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

    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    location = Column(Geography(geometry_type='POINT', srid=4326), nullable=True)

    district = relationship(
        "District",
        back_populates="markets"
    )

    mandi_prices = relationship(
        "MandiPrice",
        back_populates="market"
    )

    translations = relationship(
        "MarketTranslation",
        back_populates="market",
        cascade="all, delete-orphan"
    )