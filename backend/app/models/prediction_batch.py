from sqlalchemy import Column, Integer, String, Date, Time, DateTime
from sqlalchemy.orm import relationship
from app.core.database import Base

class PredictionBatch(Base):
    __tablename__ = "prediction_batches"

    id = Column(Integer, primary_key=True, index=True)
    prediction_date = Column(Date, nullable=False)
    prediction_time = Column(Time, nullable=False)
    model_version = Column(String(100))
    created_at = Column(DateTime)

    predictions = relationship(
        "CommodityPrediction",
        back_populates="batch",
        cascade="all, delete-orphan"
    )
