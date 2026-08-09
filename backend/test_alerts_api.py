import os
import sys
import unittest
from datetime import datetime, timezone
import uuid

# Ensure backend root is on sys.path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.core.database import Base, get_db
from app.core.security import create_access_token, hash_password
from app.models.user import User
from app.models.commodity_group import CommodityGroup
from app.models.commodity import Commodity
from app.models.district import District
from app.models.state import State
from app.models.market import Market
from app.models.alert import Alert
from app.schemas.alert import AlertCreateSchema, AlertType, AlertSeverity
from app.services.alert_service import AlertService

# Use SQLite in-memory with StaticPool for fast unit testing across sessions
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)

class TestAlertsApi(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        Base.metadata.create_all(bind=engine)
        cls.db = TestingSessionLocal()

        # Seed minimal database dependencies
        state = State(id=1, name="Kerala")
        district = District(id=1, state_id=1, name="Thrissur")
        market = Market(id=52, district_id=1, name="Thrissur Mandi")
        comm_group = CommodityGroup(id=1, name="Vegetables")
        commodity = Commodity(id=19, name="Tomato", commodity_group_id=1)

        cls.db.add_all([state, district, market, comm_group, commodity])
        cls.db.commit()

        # Seed test user
        user = User(
            id=uuid.uuid4(),
            name="Test Farmer",
            email="farmer@example.com",
            password_hash=hash_password("password123"),
            registration_method="email",
            is_verified=True,
            state_id=1,
            district_id=1,
            preferred_language="en",
        )
        cls.db.add(user)
        cls.db.commit()
        cls.db.refresh(user)

        cls.user = user
        cls.token = create_access_token({"sub": str(user.id)})
        cls.headers = {"Authorization": f"Bearer {cls.token}"}

    @classmethod
    def tearDownClass(cls):
        cls.db.close()
        Base.metadata.drop_all(bind=engine)

    def test_01_openapi_routes_registered(self):
        response = client.get("/openapi.json")
        self.assertEqual(response.status_code, 200)
        paths = response.json().get("paths", {})
        self.assertIn("/alerts", paths)
        self.assertIn("/alerts/history", paths)

    def test_02_unauthenticated_requests_fail(self):
        res1 = client.get("/alerts")
        self.assertEqual(res1.status_code, 401)

        res2 = client.get("/alerts/history")
        self.assertEqual(res2.status_code, 401)

    def test_03_invalid_page_size_rejected(self):
        res = client.get("/alerts?page_size=100", headers=self.headers)
        self.assertEqual(res.status_code, 400)
        self.assertIn("page_size", res.json().get("detail", "").lower())

    def test_04_market_glut_and_invalid_type_rejected(self):
        res1 = client.get("/alerts?type=MARKET_GLUT", headers=self.headers)
        self.assertEqual(res1.status_code, 400)
        self.assertIn("Invalid alert type", res1.json().get("detail", ""))

        res2 = client.get("/alerts/history?type=INVALID_TYPE", headers=self.headers)
        self.assertEqual(res2.status_code, 400)

    def test_05_invalid_date_format_rejected(self):
        res = client.get("/alerts/history?date_from=invalid-date", headers=self.headers)
        self.assertEqual(res.status_code, 400)
        self.assertIn("Invalid date format", res.json().get("detail", ""))

    def test_06_get_alerts_empty_state(self):
        res = client.get("/alerts", headers=self.headers)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["page"], 1)
        self.assertEqual(data["page_size"], 20)
        self.assertEqual(data["total"], 0)
        self.assertEqual(data["items"], [])

    def test_07_create_and_fetch_alerts_matching_contract(self):
        # Create a PRICE_INCREASE alert
        alert1 = AlertService.create_alert(
            self.db,
            AlertCreateSchema(
                user_id=self.user.id,
                type=AlertType.PRICE_INCREASE,
                severity=AlertSeverity.HIGH,
                title="Tomato price increased",
                message="Tomato prices increased by 14% in Thrissur Mandi.",
                commodity_id=19,
                market_id=52,
                current_price=2800.0,
                previous_price=2450.0,
                change_percent=14.29,
            ),
        )

        # Create an AI_RECOMMENDATION alert with NULL price
        alert2 = AlertService.create_alert(
            self.db,
            AlertCreateSchema(
                user_id=self.user.id,
                type=AlertType.AI_RECOMMENDATION,
                severity=AlertSeverity.MEDIUM,
                title="Hold Tomato sales",
                message="AI models predict 15% price rally for Tomato.",
                commodity_id=19,
                market_id=52,
                current_price=None,
                previous_price=None,
                change_percent=None,
            ),
        )

        # Fetch /alerts
        res = client.get("/alerts", headers=self.headers)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["total"], 2)
        self.assertEqual(len(data["items"]), 2)

        # Inspect first item (latest created, AI_RECOMMENDATION)
        item1 = data["items"][0]
        self.assertEqual(item1["type"], "AI_RECOMMENDATION")
        self.assertEqual(item1["title"], "Hold Tomato sales")
        self.assertEqual(item1["commodity"]["name"], "Tomato")
        self.assertEqual(item1["market"]["name"], "Thrissur Mandi")
        self.assertIsNone(item1["price"]) # Price is null!

        # Inspect second item (PRICE_INCREASE)
        item2 = data["items"][1]
        self.assertEqual(item2["type"], "PRICE_INCREASE")
        self.assertEqual(item2["price"]["current"], 2800.0)
        self.assertEqual(item2["price"]["previous"], 2450.0)
        self.assertEqual(item2["price"]["change_percent"], 14.29)

    def test_08_history_filtering_and_search(self):
        # Filter by type
        res1 = client.get("/alerts/history?type=PRICE_INCREASE", headers=self.headers)
        self.assertEqual(res1.status_code, 200)
        data1 = res1.json()
        self.assertEqual(data1["total"], 1)
        self.assertEqual(data1["items"][0]["type"], "PRICE_INCREASE")

        # Search query
        res2 = client.get("/alerts/history?search=rally", headers=self.headers)
        self.assertEqual(res2.status_code, 200)
        data2 = res2.json()
        self.assertEqual(data2["total"], 1)
        self.assertEqual(data2["items"][0]["type"], "AI_RECOMMENDATION")

        # Date query
        today_str = datetime.now().strftime("%Y-%m-%d")
        res3 = client.get(f"/alerts/history?date_from={today_str}&date_to={today_str}", headers=self.headers)
        self.assertEqual(res3.status_code, 200)
        data3 = res3.json()
        self.assertEqual(data3["total"], 2)

if __name__ == "__main__":
    unittest.main()
