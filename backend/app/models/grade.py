from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.core.database import Base


class Grade(Base):
    __tablename__ = "grade"

    id = Column(Integer, primary_key=True, index=True)

    grade_name = Column(String, nullable=False)

    mandi_prices = relationship(
        "MandiPrice",
        back_populates="grade"
    )