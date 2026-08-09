import os
import sys
from dotenv import load_dotenv

# Ensure backend directory is in path
current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.dirname(current_dir)
sys.path.insert(0, backend_dir)

from app.core.database import SessionLocal
from app.services.alert_generation_service import AlertGenerationService

load_dotenv()

def run_alerts():
    print("Starting Alert Generation Pipeline...")
    db = SessionLocal()
    try:
        service = AlertGenerationService()
        total_created = service.run_alert_generation(db)
        print(f"Alert Generation Pipeline Completed. Generated {total_created} new alerts.")
    except Exception as e:
        print(f"Error during alert generation: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    run_alerts()
