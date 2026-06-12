from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.core.database import Base


class Commodity(Base):
    __tablename__ = "commodities"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, nullable=False)

    commodity_group_id = Column(
        Integer,
        ForeignKey("commodities_group.id"),
        nullable=False
    )

    commodity_group = relationship(
        "CommodityGroup",
        back_populates="commodities"
    )

    varieties = relationship(
        "Variety",
        back_populates="commodity"
    )

    mandi_prices = relationship(
        "MandiPrice",
        back_populates="commodity"
    )