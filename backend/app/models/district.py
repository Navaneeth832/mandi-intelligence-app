from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.core.database import Base


class District(Base):
    __tablename__ = "districts"

    id = Column(Integer, primary_key=True, index=True)

    state_id = Column(
        Integer,
        ForeignKey("states.id"),
        nullable=False
    )

    name = Column(String, nullable=False)

    state = relationship(
        "State",
        back_populates="districts"
    )

    markets = relationship(
        "Market",
        back_populates="district"
    )