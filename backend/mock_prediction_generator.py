
import os
import re
import random
from collections import defaultdict
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

DATABASE_URL=os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL not found in .env")

SQL_TEMPLATE="mock_predictions_batch15_7days.sql"

engine=create_engine(DATABASE_URL)

sql=open(SQL_TEMPLATE,"r",encoding="utf-8").read()

pattern=re.compile(
r"VALUES \((\d+),\d+,(\d+),(\d+),(\d+),(\d+),'([\d-]+)',([\d.]+),'([\d:\- ]+)'\)"
)

rows=pattern.findall(sql)
if len(rows)!=140:
    raise RuntimeError(f"Expected 140 rows, found {len(rows)}")

groups=defaultdict(list)
for _,market,commodity,variety,grade,pred_date,price,created in rows:
    groups[(int(market),int(commodity),int(variety),int(grade))].append((pred_date,float(price)))

today=datetime.now(ZoneInfo("Asia/Kolkata")).date()

with engine.begin() as conn:
    # repair sequence if needed
    conn.execute(text("""
    SELECT setval(
      pg_get_serial_sequence('prediction_batches','id'),
      COALESCE((SELECT MAX(id) FROM prediction_batches),1),
      true
    )
    """))

    batch_id=conn.execute(text("""
    INSERT INTO prediction_batches(prediction_date,prediction_time,model_version,created_at)
    VALUES(:d,'09:00:00','mock-v4',NOW())
    ON CONFLICT (prediction_date, prediction_time)
    DO UPDATE SET model_version=EXCLUDED.model_version, created_at=NOW()
    RETURNING id
    """),{"d":today}).scalar_one()

    conn.execute(
        text("DELETE FROM commodity_predictions WHERE batch_id=:batch"),
        {"batch":batch_id}
    )

    conn.execute(text("""
    SELECT setval(
      pg_get_serial_sequence('commodity_predictions','id'),
      COALESCE((SELECT MAX(id) FROM commodity_predictions),1),
      true
    )
    """))

    next_id=conn.execute(text("SELECT nextval(pg_get_serial_sequence('commodity_predictions','id'))")).scalar_one()

    inserted=0

    for combo,data in groups.items():
        market,commodity,variety,grade=combo

        data=sorted(data,key=lambda x:x[0])

        prices=[p for _,p in data]

        factor=random.uniform(0.97,1.03)

        varied=[round(p*factor+random.uniform(-8,8),2) for p in prices]

        for i,price in enumerate(varied):
            pred_date=today+timedelta(days=i+1)

            conn.execute(text("""
            INSERT INTO commodity_predictions
            (
                id,
                batch_id,
                market_id,
                commodity_id,
                variety_id,
                grade_id,
                prediction_day,
                predicted_price,
                created_at
            )
            VALUES
            (
                :id,
                :batch,
                :market,
                :commodity,
                :variety,
                :grade,
                :pday,
                :price,
                NOW()
            )
            """),{
                "id":next_id,
                "batch":batch_id,
                "market":market,
                "commodity":commodity,
                "variety":variety,
                "grade":grade,
                "pday":pred_date,
                "price":price
            })
            next_id+=1
            inserted+=1

print(f"Created batch {batch_id}")
print(f"Inserted {inserted} predictions")
