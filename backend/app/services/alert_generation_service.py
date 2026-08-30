from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from app.schemas.alert import AlertCreateSchema
from app.services.alert_service import AlertService
from app.services.alert_processors.price_shift_processor import PriceShiftProcessor
from app.services.alert_processors.ai_recommendation_processor import AIRecommendationProcessor
from app.services.alert_processor_interface import AlertProcessorInterface
class AlertGenerationService:
    """
    Service coordinating alert generation processors and saving generated alerts to the database.
    """

    def __init__(self):
        self._processors: List[AlertProcessorInterface] = []
        # Register core processors
        self.register_processor(PriceShiftProcessor())
        self.register_processor(AIRecommendationProcessor())

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
