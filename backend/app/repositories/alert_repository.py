from typing import Optional, List, Tuple
from datetime import datetime, timezone, time
from uuid import UUID
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from app.models.alert import Alert
from app.models.commodity import Commodity
from app.models.market import Market
from app.schemas.alert import AlertCreateSchema

class AlertRepository:
    """Data access repository for alerts persistence and queries."""

    @staticmethod
    def get_user_alerts(
        db: Session,
        user_id: UUID,
        alert_type: Optional[str] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> Tuple[List[Alert], int]:
        today_start = datetime.combine(datetime.now(timezone.utc).date(), time.min)
        query = (
            db.query(Alert)
            .options(joinedload(Alert.commodity), joinedload(Alert.market))
            .filter(Alert.user_id == user_id)
            .filter(Alert.created_at >= today_start)
        )

        if alert_type and alert_type.upper() != "ALL":
            query = query.filter(Alert.type == alert_type.upper())

        total = query.count()

        items = (
            query.order_by(Alert.created_at.desc(), Alert.id.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )

        return items, total

    @staticmethod
    def get_user_alert_history(
        db: Session,
        user_id: UUID,
        alert_type: Optional[str] = None,
        search: Optional[str] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None,
        page: int = 1,
        page_size: int = 20,
    ) -> Tuple[List[Alert], int]:
        query = (
            db.query(Alert)
            .join(Commodity, Alert.commodity_id == Commodity.id)
            .join(Market, Alert.market_id == Market.id)
            .options(joinedload(Alert.commodity), joinedload(Alert.market))
            .filter(Alert.user_id == user_id)
        )

        if alert_type and alert_type.upper() != "ALL":
            query = query.filter(Alert.type == alert_type.upper())

        if search and search.strip():
            q_pattern = f"%{search.strip()}%"
            query = query.filter(
                or_(
                    Alert.title.ilike(q_pattern),
                    Alert.message.ilike(q_pattern),
                    Commodity.name.ilike(q_pattern),
                    Market.name.ilike(q_pattern),
                )
            )

        if date_from:
            query = query.filter(Alert.created_at >= date_from)

        if date_to:
            query = query.filter(Alert.created_at <= date_to)

        total = query.count()

        items = (
            query.order_by(Alert.created_at.desc(), Alert.id.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )

        return items, total

    @staticmethod
    def create_alert(db: Session, alert_data: AlertCreateSchema) -> Alert:
        alert = Alert(
            user_id=alert_data.user_id,
            type=alert_data.type.value if hasattr(alert_data.type, "value") else str(alert_data.type),
            severity=alert_data.severity.value if hasattr(alert_data.severity, "value") else str(alert_data.severity),
            title=alert_data.title,
            message=alert_data.message,
            commodity_id=alert_data.commodity_id,
            market_id=alert_data.market_id,
            current_price=alert_data.current_price,
            previous_price=alert_data.previous_price,
            change_percent=alert_data.change_percent,
        )
        db.add(alert)
        db.commit()
        db.refresh(alert)
        return alert
