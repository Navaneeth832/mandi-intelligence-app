from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.core.database import Base


class Variety(Base):
    __tablename__ = "varieties"

    id = Column(Integer, primary_key=True, index=True)

    commodity_id = Column(
        Integer,
        ForeignKey("commodities.id"),
        nullable=False
    )

    name = Column(String, nullable=False)

    commodity = relationship(
        "Commodity",
        back_populates="varieties"
    )

    mandi_prices = relationship(
        "MandiPrice",
        back_populates="variety"
    )