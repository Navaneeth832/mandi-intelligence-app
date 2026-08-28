import sys
import os

# Add the backend directory to sys.path so we can import app modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_compare():
    print("\nTesting /markets/compare")
    # Using a typical commodity_id, for example 1 or whatever exists in the db
    response = client.get("/markets/compare?lat=9.5916&lng=76.5222&commodity_id=19")
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Compared {len(data.get('markets', []))} markets.")
        for m in data.get('markets', [])[:3]:
            print(f"{m['market_name']} - dist: {m['distance_km']}km, price: {m['selling_price']}, profit: {m['net_profit']}, best: {m['is_best_value']}")
    else:
        print(response.text)

if __name__ == "__main__":
    test_compare()
