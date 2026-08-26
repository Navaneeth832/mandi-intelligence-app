import os
import sys
import unittest
from unittest.mock import patch, MagicMock
import uuid

# Ensure backend root is on sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

# Mock dependencies if not installed in local environment
for mod in ["lightgbm", "resend", "twilio", "twilio.rest"]:
    try:
        __import__(mod)
    except ImportError:
        sys.modules[mod] = MagicMock()

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.database import Base
from app.models.user import User
from app.models.commodity_group import CommodityGroup
from app.models.commodity import Commodity
from app.models.district import District
from app.models.state import State
from app.models.market import Market
from app.models.notification_preference import NotificationPreference
from app.schemas.alert import AlertCreateSchema, AlertType, AlertSeverity
from app.services.alert_service import AlertService
from app.services.email_service import EmailService

SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class TestEmailAlertDelivery(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        Base.metadata.create_all(bind=engine)
        cls.db = TestingSessionLocal()

        state = State(id=1, name="Kerala")
        district = District(id=1, state_id=1, name="Palakkad")
        market = Market(id=10, district_id=1, name="Palakkad Mandi")
        comm_group = CommodityGroup(id=1, name="Fruits")
        commodity = Commodity(id=5, name="Banana", commodity_group_id=1)

        cls.db.add_all([state, district, market, comm_group, commodity])
        cls.db.commit()

        # Seed English user
        cls.user_en = User(
            id=uuid.uuid4(),
            name="John Farmer",
            email="john@example.com",
            password_hash="hash",
            registration_method="email",
            is_verified=True,
            preferred_language="en",
        )
        # Seed Hindi user
        cls.user_hi = User(
            id=uuid.uuid4(),
            name="राम किसान",
            email="ram@example.com",
            password_hash="hash",
            registration_method="email",
            is_verified=True,
            preferred_language="hi",
        )
        # Seed Malayalam user
        cls.user_ml = User(
            id=uuid.uuid4(),
            name="രമേഷ് കർഷകൻ",
            email="ramesh@example.com",
            password_hash="hash",
            registration_method="email",
            is_verified=True,
            preferred_language="ml",
        )
        # Seed Phone User (No Email)
        cls.user_phone = User(
            id=uuid.uuid4(),
            name="Phone Farmer",
            phone_number="+919876543210",
            email=None,
            password_hash="hash",
            registration_method="phone",
            is_verified=True,
            preferred_language="en",
        )

        cls.db.add_all([cls.user_en, cls.user_hi, cls.user_ml, cls.user_phone])
        cls.db.commit()

        # Add NotificationPreferences enabling delivery_email for test users
        cls.db.add_all([
            NotificationPreference(user_id=cls.user_en.id, delivery_email=True),
            NotificationPreference(user_id=cls.user_hi.id, delivery_email=True),
            NotificationPreference(user_id=cls.user_ml.id, delivery_email=True),
            NotificationPreference(user_id=cls.user_phone.id, delivery_email=True),
        ])
        cls.db.commit()

    @classmethod
    def tearDownClass(cls):
        cls.db.close()
        Base.metadata.drop_all(bind=engine)

    @patch("resend.Emails.send")
    def test_01_price_increase_email_english(self, mock_send):
        mock_send.return_value = {"id": "msg_123"}
        alert_data = AlertCreateSchema(
            user_id=self.user_en.id,
            type=AlertType.PRICE_INCREASE,
            severity=AlertSeverity.HIGH,
            title="Price Rise Alert",
            message="Banana price increased by 12%",
            commodity_id=5,
            market_id=10,
            current_price=2800.0,
            previous_price=2500.0,
            change_percent=12.0,
        )
        alert = AlertService.create_alert(self.db, alert_data)
        self.assertIsNotNone(alert.id)
        mock_send.assert_called_once()
        call_kwargs = mock_send.call_args[0][0]
        self.assertEqual(call_kwargs["to"], "john@example.com")
        self.assertIn("Banana price increased", call_kwargs["subject"])
        self.assertIn("Banana", call_kwargs["html"])
        self.assertIn("Palakkad Mandi", call_kwargs["html"])

    @patch("resend.Emails.send")
    def test_02_price_drop_email_hindi(self, mock_send):
        mock_send.return_value = {"id": "msg_456"}
        alert_data = AlertCreateSchema(
            user_id=self.user_hi.id,
            type=AlertType.PRICE_DROP,
            severity=AlertSeverity.HIGH,
            title="कीमत घटी अलर्ट",
            message="केला की कीमत 10% घटी",
            commodity_id=5,
            market_id=10,
            current_price=2200.0,
            previous_price=2444.0,
            change_percent=-10.0,
        )
        alert = AlertService.create_alert(self.db, alert_data)
        self.assertIsNotNone(alert.id)
        mock_send.assert_called_once()
        call_kwargs = mock_send.call_args[0][0]
        self.assertEqual(call_kwargs["to"], "ram@example.com")
        self.assertIn("कीमत घटी", call_kwargs["subject"])

    @patch("resend.Emails.send")
    def test_03_market_glut_email_malayalam(self, mock_send):
        mock_send.return_value = {"id": "msg_789"}
        alert_data = AlertCreateSchema(
            user_id=self.user_ml.id,
            type=AlertType.BETTER_MARKET,
            severity=AlertSeverity.MEDIUM,
            title="മണ്ഡി അലേർട്ട്",
            message="മെച്ചപ്പെട്ട വിപണി ലഭ്യമാണ്",
            commodity_id=5,
            market_id=10,
            current_price=3000.0,
            previous_price=2800.0,
            change_percent=7.1,
        )
        alert = AlertService.create_alert(self.db, alert_data)
        self.assertIsNotNone(alert.id)
        mock_send.assert_called_once()
        call_kwargs = mock_send.call_args[0][0]
        self.assertEqual(call_kwargs["to"], "ramesh@example.com")
        self.assertIn("മെച്ചപ്പെട്ട വിപണി", call_kwargs["subject"])

    @patch("resend.Emails.send")
    def test_04_user_without_email_skips_cleanly(self, mock_send):
        alert_data = AlertCreateSchema(
            user_id=self.user_phone.id,
            type=AlertType.PRICE_INCREASE,
            severity=AlertSeverity.MEDIUM,
            title="Price Rise Alert",
            message="Banana price increased",
            commodity_id=5,
            market_id=10,
            current_price=2800.0,
        )
        alert = AlertService.create_alert(self.db, alert_data)
        self.assertIsNotNone(alert.id)
        mock_send.assert_not_called()

    @patch("resend.Emails.send")
    def test_05_resend_failure_does_not_fail_alert_creation(self, mock_send):
        mock_send.side_effect = Exception("Resend API key error / rate limited")
        alert_data = AlertCreateSchema(
            user_id=self.user_en.id,
            type=AlertType.AI_RECOMMENDATION,
            severity=AlertSeverity.LOW,
            title="Market Advisory",
            message="Plan your harvest for maximum profit",
            commodity_id=5,
            market_id=10,
        )
        alert = AlertService.create_alert(self.db, alert_data)
        self.assertIsNotNone(alert.id)
        mock_send.assert_called_once()

    @patch("resend.Emails.send")
    def test_06_existing_otp_email_still_works(self, mock_send):
        mock_send.return_value = {"id": "msg_otp"}
        EmailService.send_otp_email("test@example.com", "123456")
        mock_send.assert_called_once()
        call_kwargs = mock_send.call_args[0][0]
        self.assertEqual(call_kwargs["to"], "test@example.com")
        self.assertIn("123456", call_kwargs["html"])


if __name__ == "__main__":
    unittest.main()
