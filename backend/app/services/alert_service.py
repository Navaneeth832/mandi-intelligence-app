import logging
from typing import Optional, List
from datetime import datetime
from uuid import UUID
from sqlalchemy.orm import Session

from app.models.alert import Alert
from app.models.user import User
from app.models.notification_preference import NotificationPreference
from app.repositories.alert_repository import AlertRepository
from app.schemas.alert import (
    AlertSchema,
    AlertCommoditySchema,
    AlertMarketSchema,
    AlertPriceSchema,
    PaginatedAlertsResponse,
    AlertCreateSchema,
    AlertType,
)

from app.services.alert_localization import AlertLocalizationService
from app.services.email_service import EmailService

logger = logging.getLogger(__name__)


class AlertService:
    """Service layer for fetching user alerts and managing integration boundaries."""

    @staticmethod
    def _map_to_schema(alert: Alert, db: Session, lang: str = "en") -> AlertSchema:
        price_schema: Optional[AlertPriceSchema] = None
        if alert.current_price is not None:
            price_schema = AlertPriceSchema(
                current=float(alert.current_price),
                previous=float(alert.previous_price) if alert.previous_price is not None else None,
                change_percent=float(alert.change_percent) if alert.change_percent is not None else None,
            )

        # Dynamically localize title and message if possible
        try:
            alert_type_obj = AlertType(alert.type) if isinstance(alert.type, str) else alert.type
            title, message = AlertLocalizationService.build_localized_alert(
                db=db,
                user_lang=lang,
                alert_type=alert_type_obj,
                commodity_id=alert.commodity_id,
                market_id=alert.market_id,
                price_change=float(alert.change_percent) if alert.change_percent is not None else None
            )
        except Exception:
            title = alert.title
            message = alert.message

        # Dynamically localize commodity and market names
        commodity_name = AlertLocalizationService.get_translated_commodity(db, alert.commodity_id, lang)
        market_name = AlertLocalizationService.get_translated_market(db, alert.market_id, lang)

        return AlertSchema(
            id=alert.id,
            type=alert.type,
            severity=alert.severity,
            title=title,
            message=message,
            commodity=AlertCommoditySchema(
                id=alert.commodity.id,
                name=commodity_name,
            ),
            market=AlertMarketSchema(
                id=alert.market.id,
                name=market_name,
            ),
            price=price_schema,
            created_at=alert.created_at,
        )

    @classmethod
    def get_alerts(
        cls,
        db: Session,
        user: User,
        type: Optional[str] = None,
        language: str = "en",
        page: int = 1,
        page_size: int = 20,
    ) -> PaginatedAlertsResponse:
        items, total = AlertRepository.get_user_alerts(
            db=db,
            user_id=user.id,
            alert_type=type,
            page=page,
            page_size=page_size,
        )

        schema_items = [cls._map_to_schema(item, db=db, lang=language) for item in items]
        return PaginatedAlertsResponse(
            items=schema_items,
            page=page,
            page_size=page_size,
            total=total,
        )

    @classmethod
    def get_alert_history(
        cls,
        db: Session,
        user: User,
        type: Optional[str] = None,
        search: Optional[str] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None,
        language: str = "en",
        page: int = 1,
        page_size: int = 20,
    ) -> PaginatedAlertsResponse:
        items, total = AlertRepository.get_user_alert_history(
            db=db,
            user_id=user.id,
            alert_type=type,
            search=search,
            date_from=date_from,
            date_to=date_to,
            page=page,
            page_size=page_size,
        )

        schema_items = [cls._map_to_schema(item, db=db, lang=language) for item in items]
        return PaginatedAlertsResponse(
            items=schema_items,
            page=page,
            page_size=page_size,
            total=total,
        )

    @classmethod
    def _send_alert_email_notification(cls, db: Session, alert: Alert) -> bool:
        user = db.query(User).filter(User.id == alert.user_id).first()
        if not user or not user.email or not user.email.strip():
            logger.info(f"Skipping alert email: User {alert.user_id} has no valid email address.")
            return False

        # Respect user email notification preference if preference record exists
        prefs = db.query(NotificationPreference).filter(NotificationPreference.user_id == user.id).first()
        if prefs and not prefs.delivery_email:
            logger.info(f"Skipping alert email for user {user.id}: delivery_email is disabled.")
            return False

        lang = user.preferred_language or "en"
        commodity_name = AlertLocalizationService.get_translated_commodity(db, alert.commodity_id, lang)
        market_name = AlertLocalizationService.get_translated_market(db, alert.market_id, lang)

        return EmailService.send_alert_email(
            email=user.email,
            user_name=user.name,
            lang=lang,
            alert_type=alert.type,
            commodity_name=commodity_name,
            market_name=market_name,
            title=alert.title,
            message=alert.message,
            current_price=float(alert.current_price) if alert.current_price is not None else None,
            previous_price=float(alert.previous_price) if alert.previous_price is not None else None,
            change_percent=float(alert.change_percent) if alert.change_percent is not None else None,
        )

    @classmethod
    def create_alert(cls, db: Session, alert_data: AlertCreateSchema) -> Alert:
        """Integration boundary helper to persist alerts generated by AI/ML business logic."""
        alert = AlertRepository.create_alert(db, alert_data)

        # Trigger email delivery channel independently; failure will not rollback alert
        try:
            cls._send_alert_email_notification(db, alert)
        except Exception as e:
            logger.error(f"Error executing email notification for alert ID {alert.id}: {e}")

        return alert
