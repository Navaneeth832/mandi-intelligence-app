from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship

from app.core.database import Base


class MarketTranslation(Base):
    __tablename__ = "market_translations"

    id = Column(Integer, primary_key=True, index=True)

    market_id = Column(
        Integer,
        ForeignKey("markets.id"),
        nullable=False
    )

    language_code = Column(String(2), nullable=False)

    translated_name = Column(String, nullable=False)

    __table_args__ = (
        UniqueConstraint('market_id', 'language_code', name='uq_market_lang'),
    )

    market = relationship(
        "Market",
        back_populates="translations"
    )
