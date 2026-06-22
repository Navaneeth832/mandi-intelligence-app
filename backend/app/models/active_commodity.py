from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship

from app.core.database import Base


class ActiveCommodity(Base):
    __tablename__ = "active_commodity"

    id = Column(Integer, primary_key=True, index=True)
    commodity_id = Column(
        Integer,
        ForeignKey("commodities.id", ondelete="CASCADE"),
        nullable=False,
        unique=True
    )

    commodity = relationship("Commodity", back_populates="active_commodity")
