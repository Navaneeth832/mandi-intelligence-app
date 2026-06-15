from sqlalchemy import text
from app.core.database import Base, engine
from app.models import *

Base.metadata.create_all(bind=engine)

# Safely apply the unique constraint if it doesn't already exist in the database
with engine.begin() as connection:
    try:
        connection.execute(text("""
            ALTER TABLE mandi_prices
            ADD CONSTRAINT mandi_prices_unique
            UNIQUE (
                commodity_id,
                variety_id,
                grade_id,
                market_id,
                arrival_date
            );
        """))
        print("Unique constraint added successfully!")
    except Exception as e:
        # Constraint might already exist, catch safely so schema generation is successful
        print("Note: Unique constraint not added (it may already exist).")

print("Tables created successfully!")