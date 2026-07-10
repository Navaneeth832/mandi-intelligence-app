from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship

from app.core.database import Base


class StateTranslation(Base):
    __tablename__ = "state_translations"

    id = Column(Integer, primary_key=True, index=True)

    state_id = Column(
        Integer,
        ForeignKey("states.id"),
        nullable=False
    )

    language_code = Column(String(2), nullable=False)

    translated_name = Column(String, nullable=False)

    __table_args__ = (
        UniqueConstraint('state_id', 'language_code', name='uq_state_lang'),
    )

    state = relationship(
        "State",
        back_populates="translations"
    )
