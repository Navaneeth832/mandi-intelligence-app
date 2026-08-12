from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from app.schemas.alert import AlertCreateSchema

class AlertProcessorInterface(ABC):
    """
    Integration boundary interface for alert generation pipeline.
    """

    @abstractmethod
    def evaluate_and_generate_alerts(
        self,
        db: Session,
        user_id: Optional[UUID] = None,
    ) -> List[AlertCreateSchema]:
        """
        Evaluate market conditions, price movements, or AI prediction trajectories
        and return a list of AlertCreateSchema objects ready for persistence.
        """
        pass
