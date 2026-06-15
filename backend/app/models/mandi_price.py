from sqlalchemy import (
    Column,
    Integer,
    Numeric,
    Date,
    DateTime,
    ForeignKey,
    UniqueConstraint
)
from sqlalchemy.orm import relationship
from datetime import datetime

from app.core.database import Base


class MandiPrice(Base):
    __tablename__ = "mandi_prices"

    __table_args__ = (
        UniqueConstraint(
            "commodity_id",
            "variety_id",
            "grade_id",
            "market_id",
            "arrival_date",
            name="mandi_prices_unique"
        ),
    )

    id = Column(Integer, primary_key=True, index=True)

    commodity_id = Column(
        Integer,
        ForeignKey("commodities.id"),
        nullable=False
    )

    variety_id = Column(
        Integer,
        ForeignKey("varieties.id"),
        nullable=False
    )

    grade_id = Column(
        Integer,
        ForeignKey("grade.id"),
        nullable=False
    )

    market_id = Column(
        Integer,
        ForeignKey("markets.id"),
        nullable=False
    )

    modal_price = Column(Numeric, nullable=False)
    min_price = Column(Numeric, nullable=False)
    max_price = Column(Numeric, nullable=False)

    arrival_date = Column(Date, nullable=False)

    created_at = Column(
        DateTime,
        default=datetime.utcnow
    )

    commodity = relationship(
        "Commodity",
        back_populates="mandi_prices"
    )

    variety = relationship(
        "Variety",
        back_populates="mandi_prices"
    )

    grade = relationship(
        "Grade",
        back_populates="mandi_prices"
    )

    market = relationship(
        "Market",
        back_populates="mandi_prices"
    )