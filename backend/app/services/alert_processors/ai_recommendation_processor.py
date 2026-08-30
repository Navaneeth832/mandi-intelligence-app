from typing import List, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from sqlalchemy import text

from app.schemas.alert import AlertCreateSchema, AlertType, AlertSeverity
from app.services.alert_processor_interface import AlertProcessorInterface
from app.services.alert_localization import AlertLocalizationService

class AIRecommendationProcessor(AlertProcessorInterface):
    """
    Finds a nearby market (top 10 closest) where the user can get a better net profit
    for their preferred commodities than their primary mandi, considering transport costs (2.5 rs/km)
    and mandi commission (1%). Assumes 1 quintal quantity.
    """
    def evaluate_and_generate_alerts(
        self,
        db: Session,
        user_id: Optional[UUID] = None,
    ) -> List[AlertCreateSchema]:
        alerts_to_create = []
        
        # 1. Evaluate Best Alternative Markets
        evaluation_sql = """
            WITH TargetUsers AS (
                SELECT u.id as user_id,
                       u.preferred_language,
                       u.preferred_market_id,
                       m.location as user_market_location,
                       ucp.commodity_id
                FROM users u
                JOIN user_crop_preferences ucp ON u.id = ucp.user_id
                JOIN notification_preferences np ON u.id = np.user_id
                JOIN markets m ON u.preferred_market_id = m.id
                WHERE np.ai_recommendation = true
                  AND m.location IS NOT NULL
        """
        
        if user_id:
            evaluation_sql += " AND u.id = :user_id"
            
        evaluation_sql += """
            ),
            TodayPrices AS (
                SELECT commodity_id, market_id, MAX(modal_price) as modal_price
                FROM mandi_prices
                WHERE arrival_date = CURRENT_DATE
                GROUP BY commodity_id, market_id
            ),
            UserMarketPrices AS (
                SELECT tu.user_id, tu.preferred_language, tu.preferred_market_id, tu.commodity_id, tu.user_market_location,
                       tp.modal_price as primary_price,
                       (tp.modal_price - tp.modal_price * 0.01) as primary_net_profit
                FROM TargetUsers tu
                JOIN TodayPrices tp ON tp.market_id = tu.preferred_market_id AND tp.commodity_id = tu.commodity_id
            ),
            NearbyMarketPrices AS (
                SELECT 
                    ump.user_id, ump.preferred_language, ump.preferred_market_id, ump.commodity_id, ump.user_market_location,
                    ump.primary_price, ump.primary_net_profit,
                    tp2.market_id as nearby_market_id,
                    tp2.modal_price as nearby_price,
                    ST_Distance(ump.user_market_location, m2.location) / 1000.0 as distance_km,
                    ROW_NUMBER() OVER(
                        PARTITION BY ump.user_id, ump.commodity_id 
                        ORDER BY ST_Distance(ump.user_market_location, m2.location) ASC
                    ) as dist_rank
                FROM UserMarketPrices ump
                JOIN TodayPrices tp2 ON tp2.commodity_id = ump.commodity_id
                JOIN markets m2 ON m2.id = tp2.market_id
                WHERE m2.location IS NOT NULL
            ),
            TopNearbyMarkets AS (
                SELECT *,
                       (nearby_price - nearby_price * 0.01 - (distance_km * 2.5)) as nearby_net_profit
                FROM NearbyMarketPrices 
                WHERE dist_rank <= 10 AND nearby_market_id != preferred_market_id
            ),
            BestAlternativeMarket AS (
                SELECT *,
                    ROW_NUMBER() OVER(
                        PARTITION BY user_id, commodity_id 
                        ORDER BY nearby_net_profit DESC
                    ) as profit_rank
                FROM TopNearbyMarkets
            )
            SELECT 
                user_id, preferred_language, preferred_market_id, commodity_id,
                primary_price, primary_net_profit,
                nearby_market_id as recommended_market_id,
                nearby_price as recommended_price,
                nearby_net_profit,
                ((nearby_net_profit - primary_net_profit) / NULLIF(primary_net_profit, 0)) * 100 as profit_increase_percent
            FROM BestAlternativeMarket 
            WHERE profit_rank = 1 AND nearby_net_profit > primary_net_profit
        """
        
        params = {}
        if user_id:
            params["user_id"] = str(user_id)
            
        evaluation_query = text(evaluation_sql)
        recommendations = db.execute(evaluation_query, params).fetchall()
        
        if not recommendations:
            return []

        # 2. Fetch existing AI_RECOMMENDATION alerts created today for deduplication
        existing_alerts_query = text("""
            SELECT user_id, commodity_id, market_id, type
            FROM alerts
            WHERE DATE(created_at AT TIME ZONE 'UTC') = CURRENT_DATE
              AND type = 'AI_RECOMMENDATION'
        """)
        existing_rows = db.execute(existing_alerts_query).fetchall()
        existing_alert_keys = {
            (row.user_id, row.commodity_id, row.market_id, str(row.type))
            for row in existing_rows
        }

        # 3. Generate localized alerts
        for rec in recommendations:
            alert_type = AlertType.AI_RECOMMENDATION
            type_str = alert_type.value if hasattr(alert_type, "value") else str(alert_type)

            # Deduplication check
            if (rec.user_id, rec.commodity_id, rec.recommended_market_id, type_str) in existing_alert_keys:
                continue

            profit_pct = rec.profit_increase_percent or 0.0
            severity = AlertSeverity.HIGH if profit_pct >= 10.0 else AlertSeverity.MEDIUM
            
            title, message = AlertLocalizationService.build_localized_alert(
                db=db,
                user_lang=rec.preferred_language or "en",
                alert_type=alert_type,
                commodity_id=rec.commodity_id,
                market_id=rec.recommended_market_id,
                price_change=None # No specific price change to show in the template for AI_RECOMMENDATION usually
            )

            alert = AlertCreateSchema(
                user_id=rec.user_id,
                type=alert_type,
                severity=severity,
                title=title,
                message=message,
                commodity_id=rec.commodity_id,
                market_id=rec.recommended_market_id,
                current_price=float(rec.recommended_price),
                previous_price=float(rec.primary_price),
                change_percent=float(rec.profit_increase_percent) if rec.profit_increase_percent is not None else 0.0
            )
            alerts_to_create.append(alert)
            existing_alert_keys.add((rec.user_id, rec.commodity_id, rec.recommended_market_id, type_str))

        return alerts_to_create
