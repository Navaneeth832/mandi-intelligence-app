from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.schemas.alert import AlertCreateSchema, AlertType, AlertSeverity
from app.services.alert_processor_interface import AlertProcessorInterface
from app.services.alert_localization import AlertLocalizationService

class PriceShiftProcessor(AlertProcessorInterface):
    """
    Finds commodities where the modal price shifted by >= 10% compared to the previous day.
    Targets users tracking the commodity who are geographically relevant and have opted in.
    """
    def evaluate_and_generate_alerts(
        self,
        db: Session,
        user_id: Optional[UUID] = None,
    ) -> List[AlertCreateSchema]:
        alerts_to_create = []
        
        # 1. Find Price Shifts (>= 10% difference between today's price and the previous available price)
        # Partition by commodity_id, variety_id, grade_id, market_id to ensure like-for-like comparison
        shift_query = text("""
            WITH RankedPrices AS (
                SELECT 
                    commodity_id, variety_id, grade_id, market_id, modal_price, arrival_date,
                    ROW_NUMBER() OVER(
                        PARTITION BY commodity_id, variety_id, grade_id, market_id 
                        ORDER BY arrival_date DESC
                    ) as rn
                FROM mandi_prices
                WHERE arrival_date >= CURRENT_DATE - INTERVAL '7 days'
            ),
            LatestPrices AS (
                SELECT * FROM RankedPrices WHERE rn = 1
            ),
            PreviousPrices AS (
                SELECT * FROM RankedPrices WHERE rn = 2
            )
            SELECT 
                l.commodity_id, 
                l.market_id, 
                l.modal_price as current_price, 
                p.modal_price as previous_price,
                ROUND(ABS((l.modal_price - p.modal_price) / p.modal_price * 100), 2) as change_percent,
                CASE 
                    WHEN l.modal_price > p.modal_price THEN 'PRICE_INCREASE' 
                    ELSE 'PRICE_DROP' 
                END as shift_direction
            FROM LatestPrices l
            JOIN PreviousPrices p ON l.commodity_id = p.commodity_id 
                                 AND l.variety_id = p.variety_id 
                                 AND l.grade_id = p.grade_id 
                                 AND l.market_id = p.market_id
            WHERE l.arrival_date = CURRENT_DATE 
              AND p.modal_price > 0
              AND ABS((l.modal_price - p.modal_price) / p.modal_price) >= 0.10
        """)
        
        shifts = db.execute(shift_query).fetchall()
        if not shifts:
            return []

        # Convert shifts to a dict for easy lookup: (commodity_id, market_id) -> shift_data
        shifts_data = {
            (row.commodity_id, row.market_id): row
            for row in shifts
        }

        # 2. Fetch existing alerts created today for deduplication
        existing_alerts_query = text("""
            SELECT user_id, commodity_id, market_id, type
            FROM alerts
            WHERE DATE(created_at AT TIME ZONE 'UTC') = CURRENT_DATE
        """)
        existing_rows = db.execute(existing_alerts_query).fetchall()
        existing_alert_keys = {
            (row.user_id, row.commodity_id, row.market_id, str(row.type))
            for row in existing_rows
        }

        # 3. Find target users (filtered by shifted commodity IDs and market IDs to optimize performance)
        shifted_commodity_ids = list(set(row.commodity_id for row in shifts))
        shifted_market_ids = list(set(row.market_id for row in shifts))

        target_users_sql = """
            SELECT u.id as user_id, u.preferred_language, u.district_id,
                   ucp.commodity_id, np.price_increase, np.price_drop,
                   m.id as market_id
            FROM users u
            JOIN user_crop_preferences ucp ON u.id = ucp.user_id
            JOIN notification_preferences np ON u.id = np.user_id
            JOIN markets m ON u.district_id = m.district_id
            WHERE (np.price_increase = true OR np.price_drop = true)
              AND ucp.commodity_id = ANY(:commodity_ids)
              AND m.id = ANY(:market_ids)
        """
        
        params = {
            "commodity_ids": shifted_commodity_ids,
            "market_ids": shifted_market_ids,
        }

        if user_id:
            target_users_sql += " AND u.id = :user_id"
            params["user_id"] = str(user_id)

        target_users_query = text(target_users_sql)
        target_users = db.execute(target_users_query, params).fetchall()

        # 4. Generate localized alerts
        for user_row in target_users:
            key = (user_row.commodity_id, user_row.market_id)
            if key in shifts_data:
                shift = shifts_data[key]
                
                # Check if user wants this specific alert type
                if shift.shift_direction == 'PRICE_INCREASE' and not user_row.price_increase:
                    continue
                if shift.shift_direction == 'PRICE_DROP' and not user_row.price_drop:
                    continue

                alert_type = AlertType.PRICE_INCREASE if shift.shift_direction == 'PRICE_INCREASE' else AlertType.PRICE_DROP
                type_str = alert_type.value if hasattr(alert_type, "value") else str(alert_type)

                # Deduplication check: skip if alert already generated today for this user/commodity/market/type
                if (user_row.user_id, shift.commodity_id, shift.market_id, type_str) in existing_alert_keys:
                    continue

                severity = AlertSeverity.HIGH if shift.change_percent >= 20.0 else AlertSeverity.MEDIUM
                
                title, message = AlertLocalizationService.build_localized_alert(
                    db=db,
                    user_lang=user_row.preferred_language or "en",
                    alert_type=alert_type,
                    commodity_id=shift.commodity_id,
                    market_id=shift.market_id,
                    price_change=float(shift.change_percent)
                )

                alert = AlertCreateSchema(
                    user_id=user_row.user_id,
                    type=alert_type,
                    severity=severity,
                    title=title,
                    message=message,
                    commodity_id=shift.commodity_id,
                    market_id=shift.market_id,
                    current_price=float(shift.current_price),
                    previous_price=float(shift.previous_price),
                    change_percent=float(shift.change_percent)
                )
                alerts_to_create.append(alert)
                # Add to local tracking set to avoid duplicates within same loop iteration
                existing_alert_keys.add((user_row.user_id, shift.commodity_id, shift.market_id, type_str))

        return alerts_to_create
