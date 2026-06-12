from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.core.database import Base


class CommodityGroup(Base):
    __tablename__ = "commodities_group"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, nullable=False)

    commodities = relationship(
        "Commodity",
        back_populates="commodity_group"
    )