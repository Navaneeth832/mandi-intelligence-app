import sys
import os
import time
import logging

# Add the project root (backend) to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import joinedload
from sqlalchemy import text
from app.core.database import SessionLocal
from app.models.market import Market
from app.models.district import District
from geopy.geocoders import GoogleV3
from geopy.exc import GeocoderTimedOut, GeocoderServiceError, GeocoderQueryError
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def get_coordinates(limit=None):
    # Load environment variables
    load_dotenv(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env"))
    api_key = os.environ.get("GOOGLE_MAPS_API_KEY")
    if not api_key:
        logging.error("GOOGLE_MAPS_API_KEY environment variable not found.")
        return
        
    # Initialize Google Maps Geocoding API
    geolocator = GoogleV3(api_key=api_key)
    
    db = SessionLocal()
    
    try:
        # Fetch markets without latitude, eager-load district and state
        query = (
            db.query(Market)
            .options(joinedload(Market.district).joinedload(District.state))
            .filter(Market.latitude.is_(None))
        )
        
        if limit:
            markets = query.limit(limit).all()
        else:
            # Google API limits: max 4300 per run to be safe
            markets = query.limit(4300).all()
        
        
        logging.info(f"Found {len(markets)} markets that need geocoding.")
        
        for market in markets:
            if not market.district or not market.district.state:
                logging.warning(f"Market ID {market.id} ('{market.name}') is missing district or state relations. Skipping.")
                continue
                
            search_query = f"{market.name}, {market.district.name}, {market.district.state.name}, India"
            logging.info(f"Geocoding: {search_query}")
            
            try:
                location = geolocator.geocode(search_query, timeout=10)
                
                if location:
                    market.latitude = location.latitude
                    market.longitude = location.longitude
                    
                    # Also update PostGIS geography column using ST_MakePoint (longitude, latitude)
                    db.execute(
                        text("UPDATE markets SET location = ST_SetSRID(ST_MakePoint(:lon, :lat), 4326) WHERE id = :id"),
                        {"lon": location.longitude, "lat": location.latitude, "id": market.id}
                    )
                    
                    db.commit()
                    logging.info(f"Success! Coordinates: ({location.latitude}, {location.longitude})")
                else:
                    logging.warning(f"Could not find coordinates for: {search_query}")
                    
            except (GeocoderTimedOut, GeocoderServiceError, GeocoderQueryError) as e:
                logging.error(f"Geocoding failed for {search_query}: {e}")
                
            # Google API allows 50 requests per second. Throttling to ~20 requests per second (0.05s delay)
            time.sleep(0.05)
            
    finally:
        db.close()

if __name__ == "__main__":
    # Perform a test run for the first 10 markets
    # Set limit=None to run for the full batch (up to 4300)
    get_coordinates(limit=4300)
