from app.core.database import SessionLocal
from app.schemas.alert import AlertCreateSchema, AlertType, AlertSeverity
from app.services.alert_service import AlertService

db = SessionLocal()

alert_data = AlertCreateSchema(
    user_id="035a7944-e653-44ae-af88-44804331e838",
    type=AlertType.PRICE_INCREASE,
    severity=AlertSeverity.HIGH,
    title="Price Increase Alert",
    message="Banana price increased by 15% in Palakkad Mandi",
    commodity_id=5,  # Banana
    market_id=10,    # Palakkad Mandi
    current_price=2800.0,
    previous_price=2434.0,
    change_percent=15.0
)

# This creates the DB record AND sends the email via Resend
AlertService.create_alert(db, alert_data)
db.close()