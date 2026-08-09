from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from app.schemas.alert import AlertCreateSchema
from app.services.alert_service import AlertService

class AlertProcessorInterface(ABC):
    """
    Integration boundary interface for Raihan's AI/ML alert generation pipeline.
    Raihan will implement specific rules or ML decision trees to generate alerts.
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

class AlertGenerationService:
    """
    Service coordinating alert generation processors and saving generated alerts to the database.
    Raihan can register processors here and trigger scheduled or event-driven alert creation runs.
    """

    def __init__(self):
        self._processors: List[AlertProcessorInterface] = []

    def register_processor(self, processor: AlertProcessorInterface) -> None:
        """Register an alert processor (e.g. PriceIncreaseProcessor, BetterMarketProcessor, AIRecommendationProcessor)."""
        self._processors.append(processor)

    def run_alert_generation(
        self,
        db: Session,
        user_id: Optional[UUID] = None,
    ) -> int:
        """
        Runs all registered alert processors and persists newly generated alerts.
        Returns total number of alerts created.
        """
        total_created = 0
        for processor in self._processors:
            alert_schemas = processor.evaluate_and_generate_alerts(db, user_id=user_id)
            for alert_schema in alert_schemas:
                AlertService.create_alert(db, alert_schema)
                total_created += 1
        return total_created
