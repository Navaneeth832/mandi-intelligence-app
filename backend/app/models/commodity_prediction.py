from sqlalchemy import Column, Integer, Numeric, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base

class CommodityPrediction(Base):
    __tablename__ = "commodity_predictions"

    id = Column(Integer, primary_key=True, index=True)
    batch_id = Column(Integer, ForeignKey("prediction_batches.id"), nullable=False)
    commodity_id = Column(Integer, ForeignKey("commodities.id"), nullable=False)
    prediction_day = Column(Date, nullable=False)
    predicted_price = Column(Numeric(10, 2), nullable=False)
    created_at = Column(DateTime)

    batch = relationship("PredictionBatch", back_populates="predictions")
    commodity = relationship("Commodity")
