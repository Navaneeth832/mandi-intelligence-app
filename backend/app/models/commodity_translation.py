from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship

from app.core.database import Base


class CommodityTranslation(Base):
    __tablename__ = "commodity_translations"

    id = Column(Integer, primary_key=True, index=True)

    commodity_id = Column(
        Integer,
        ForeignKey("commodities.id"),
        nullable=False
    )

    language_code = Column(String(2), nullable=False)

    translated_name = Column(String, nullable=False)

    # Unique constraint on (commodity_id, language_code)
    __table_args__ = (
        UniqueConstraint('commodity_id', 'language_code', name='uq_commodity_lang'),
    )

    # Relationship to Commodity
    commodity = relationship(
        "Commodity",
        back_populates="translations"
    )
