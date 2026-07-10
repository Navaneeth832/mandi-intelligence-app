from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship

from app.core.database import Base


class DistrictTranslation(Base):
    __tablename__ = "district_translations"

    id = Column(Integer, primary_key=True, index=True)

    district_id = Column(
        Integer,
        ForeignKey("districts.id"),
        nullable=False
    )

    language_code = Column(String(2), nullable=False)

    translated_name = Column(String, nullable=False)

    __table_args__ = (
        UniqueConstraint('district_id', 'language_code', name='uq_district_lang'),
    )

    district = relationship(
        "District",
        back_populates="translations"
    )
