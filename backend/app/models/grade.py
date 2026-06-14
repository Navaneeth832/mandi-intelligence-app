from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.core.database import Base


class Grade(Base):
    __tablename__ = "grade"

    id = Column(Integer, primary_key=True, index=True)

    grade_name = Column(String, nullable=False)

    commodity_id = Column(
        Integer,
        ForeignKey("commodities.id"),
        nullable=False
    )

    commodity = relationship(
        "Commodity",
        back_populates="grades"
    )

    mandi_prices = relationship(
        "MandiPrice",
        back_populates="grade"
    )