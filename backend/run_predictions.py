"""
Standalone Mandi Price Prediction Script
=========================================
Fetches historical mandi price data from PostgreSQL, performs feature
engineering matching the training pipeline, runs the trained LightGBM
model, and writes the next 7-day forecasts into commodity_predictions.

Usage:
    python run_predictions.py [--days 7] [--dry-run] [--start-from-today]

Requirements:
    pip install lightgbm pandas numpy sqlalchemy python-dotenv psycopg2-binary
"""

import os
import sys
import json
import argparse
import logging
from datetime import date, timedelta, datetime, timezone
from pathlib import Path

import numpy as np
import pandas as pd
import lightgbm as lgb
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# ---------------------------------------------------------------------------
# Logging setup
# ---------------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("mandi.predict")

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
BASE_DIR = Path(__file__).resolve().parent          # .../backend/
ML_DIR   = BASE_DIR / "app" / "ml"

MODEL_PATH    = ML_DIR / "lightgbm_weights.txt"
FEATURES_PATH = ML_DIR / "model_features.json"

# ---------------------------------------------------------------------------
# Feature engineering constants (must match training)
# ---------------------------------------------------------------------------
GROUPING_COLS = ["state_name", "district_name", "market_name",
                 "cmdt_name", "variety_name", "grade_name"]

CATEGORICAL_FEATURES = ["state_name", "district_name", "market_name",
                        "cmdt_name", "grade_name", "variety_name"]

TREND_MAPPING = {"Falling": 0, "Stable": 1, "Rising": 2}

# Minimum historical records required to attempt a prediction for a group
MIN_RECORDS = 7


# ===========================================================================
# DB helpers
# ===========================================================================

def get_engine():
    load_dotenv(BASE_DIR / ".env")
    url = os.environ.get("DATABASE_URL")
    if not url:
        raise RuntimeError("DATABASE_URL is not set in .env")
    return create_engine(url)


def fetch_historical_data(engine) -> pd.DataFrame:
    """
    Pull all mandi_prices joined with commodity/market/variety/grade names
    and the full geographic hierarchy.
    Returns a raw DataFrame with columns needed for feature engineering.
    """
    sql = text("""
        SELECT
            s.name            AS state_name,
            d.name            AS district_name,
            mk.name           AS market_name,
            c.name            AS cmdt_name,
            g.grade_name      AS grade_name,
            v.name            AS variety_name,
            mp.arrival_date,
            CAST(mp.modal_price AS FLOAT)  AS model_price,
            CAST(mp.min_price   AS FLOAT)  AS min_price,
            CAST(mp.max_price   AS FLOAT)  AS max_price,
            mp.commodity_id,
            mp.market_id,
            mp.variety_id,
            mp.grade_id
        FROM mandi_prices mp
        JOIN commodities c  ON mp.commodity_id = c.id
        JOIN varieties   v  ON mp.variety_id   = v.id
        JOIN grade       g  ON mp.grade_id     = g.id
        JOIN markets     mk ON mp.market_id    = mk.id
        JOIN districts   d  ON mk.district_id  = d.id
        JOIN states      s  ON d.state_id      = s.id
        ORDER BY
            s.name, d.name, mk.name, c.name, v.name, g.grade_name,
            mp.arrival_date
    """)
    with engine.connect() as conn:
        df = pd.read_sql(sql, conn)

    log.info("Fetched %d price rows from DB.", len(df))
    df["arrival_date"] = pd.to_datetime(df["arrival_date"])
    return df


def fetch_id_map(engine):
    """
    Build lookup maps: (commodity_id, market_id, variety_id, grade_id)
    keyed on the canonical string names used in the feature DataFrame.
    """
    sql = text("""
        SELECT DISTINCT
            mp.commodity_id, mp.market_id, mp.variety_id, mp.grade_id,
            c.name   AS cmdt_name,
            mk.name  AS market_name,
            v.name   AS variety_name,
            g.grade_name,
            s.name   AS state_name,
            d.name   AS district_name
        FROM mandi_prices mp
        JOIN commodities c  ON mp.commodity_id = c.id
        JOIN varieties   v  ON mp.variety_id   = v.id
        JOIN grade       g  ON mp.grade_id     = g.id
        JOIN markets     mk ON mp.market_id    = mk.id
        JOIN districts   d  ON mk.district_id  = d.id
        JOIN states      s  ON d.state_id      = s.id
    """)
    with engine.connect() as conn:
        rows = conn.execute(sql).mappings().all()

    id_map = {}
    for r in rows:
        key = (r["cmdt_name"], r["market_name"], r["variety_name"],
               r["grade_name"], r["state_name"], r["district_name"])
        id_map[key] = (r["commodity_id"], r["market_id"],
                       r["variety_id"],   r["grade_id"])
    log.info("Built ID map with %d entries.", len(id_map))
    return id_map


# ===========================================================================
# Feature engineering 
# ===========================================================================

def compute_group_historical_stats(group_df: pd.DataFrame) -> dict:
    """
    Compute group-level static attributes derived from history:
    - alpha_volatility
    - monthly_means dict
    - overall_mean
    """
    prices = group_df["model_price"].values
    if len(prices) > 1:
        pct_changes = pd.Series(prices).pct_change(fill_method=None).dropna()
        alpha_vol = float(pct_changes.std() * 100) if len(pct_changes) > 1 else 1.5
    else:
        alpha_vol = 1.5

    if np.isnan(alpha_vol) or alpha_vol == 0:
        alpha_vol = 1.5

    overall_mean = float(np.mean(prices)) if len(prices) > 0 else 1.0

    group_df_temp = group_df.copy()
    group_df_temp["month"] = group_df_temp["arrival_date"].dt.month
    monthly_means = group_df_temp.groupby("month")["model_price"].mean().to_dict()

    return {
        "alpha_volatility": alpha_vol,
        "overall_mean": overall_mean,
        "monthly_means": monthly_means
    }


def get_feature_columns(features_path: Path) -> list[str]:
    with open(features_path) as f:
        return json.load(f)["features"]


# ===========================================================================
# Load model
# ===========================================================================

def load_model(model_path: Path) -> lgb.Booster:
    model = lgb.Booster(model_file=str(model_path))
    log.info("LightGBM model loaded: %s", model_path.name)
    return model


# ===========================================================================
# Iterative multi-step prediction
# ===========================================================================

def predict_next_n_days(
    group_df: pd.DataFrame,
    model: lgb.Booster,
    feature_cols: list[str],
    n_days: int = 7,
    start_from_today: bool = True
) -> list[tuple[date, float]]:
    """
    Given historical records for ONE commodity group, iteratively predict
    the next n_days prices starting from date.today() (or last_arrival_date + 1).

    Uses the latest available historical records (at least 7) to construct
    moving average, lag, and trend state features without NaN errors.
    """
    # Ensure data is sorted by arrival date
    group_sorted = group_df.sort_values("arrival_date").reset_index(drop=True)
    if len(group_sorted) < MIN_RECORDS:
        raise ValueError(f"Group has only {len(group_sorted)} records (minimum required: {MIN_RECORDS}).")

    stats = compute_group_historical_stats(group_sorted)

    prices_history = list(group_sorted["model_price"].values)
    
    last_arrival = group_sorted["arrival_date"].iloc[-1].date()
    today_val = date.today()

    if start_from_today and last_arrival < today_val:
        base_start_date = today_val + timedelta(days=1)
    else:
        base_start_date = last_arrival + timedelta(days=1)


    results = []

    # Get constant categoricals for this group
    sample_row = group_sorted.iloc[-1]
    group_meta = {col: sample_row[col] for col in CATEGORICAL_FEATURES}

    for i in range(n_days):
        target_date = base_start_date + timedelta(days=i)

        # 1. Date features
        dt_year = target_date.year
        dt_month = target_date.month
        dt_dow = target_date.weekday()
        dt_doy = target_date.timetuple().tm_yday
        dt_quarter = (dt_month - 1) // 3 + 1

        month_sin = np.sin(2 * np.pi * dt_month / 12.0)
        month_cos = np.cos(2 * np.pi * dt_month / 12.0)

        # 2. Lag features from existing prices history
        lag_1 = float(prices_history[-1])
        lag_3 = float(prices_history[-3]) if len(prices_history) >= 3 else lag_1
        lag_7 = float(prices_history[-7]) if len(prices_history) >= 7 else lag_1

        # 3. Moving averages (MA7, MA30) from existing prices history
        ma7 = float(np.mean(prices_history[-7:])) if len(prices_history) >= 7 else float(np.mean(prices_history))
        ma30 = float(np.mean(prices_history[-30:])) if len(prices_history) >= 30 else float(np.mean(prices_history))

        # 4. Volatility & Seasonal Index
        alpha_vol = stats["alpha_volatility"]
        month_mean = stats["monthly_means"].get(dt_month, stats["overall_mean"])
        seasonal_index = month_mean / stats["overall_mean"] if stats["overall_mean"] > 0 else 1.0

        # 5. Trend state calculation
        pct = ((lag_1 - ma30) / ma30) * 100 if ma30 > 0 else 0.0
        if (ma7 > ma30) and (lag_1 > ma7) and (pct > alpha_vol):
            trend_state = "Rising"
        elif (ma7 < ma30) and (lag_1 < ma7) and (pct < -alpha_vol):
            trend_state = "Falling"
        else:
            trend_state = "Stable"

        trend_state_encoded = TREND_MAPPING.get(trend_state, 1)

        # Construct single feature dict
        row_dict = {
            "state_name": group_meta["state_name"],
            "district_name": group_meta["district_name"],
            "market_name": group_meta["market_name"],
            "cmdt_name": group_meta["cmdt_name"],
            "grade_name": group_meta["grade_name"],
            "variety_name": group_meta["variety_name"],
            "year": dt_year,
            "month": dt_month,
            "day_of_week": dt_dow,
            "day_of_year": dt_doy,
            "quarter": dt_quarter,
            "month_sin": month_sin,
            "month_cos": month_cos,
            "model_price_lag_1": lag_1,
            "model_price_lag_3": lag_3,
            "model_price_lag_7": lag_7,
            "MA7": ma7,
            "MA30": ma30,
            "alpha_volatility": alpha_vol,
            "seasonal_index": seasonal_index,
            "trend_state_encoded": trend_state_encoded
        }

        row_df = pd.DataFrame([row_dict])

        # Cast categorical features
        for col in CATEGORICAL_FEATURES:
            row_df[col] = row_df[col].astype("category")

        X = row_df[feature_cols]

        pred_price = float(model.predict(X, num_iteration=model.best_iteration)[0])
        pred_price = max(pred_price, 0.0)  # Price lower bound

        results.append((target_date, round(pred_price, 2)))

        # Append prediction back into prices history for subsequent day lags
        prices_history.append(pred_price)

    return results


# ===========================================================================
# DB write helpers
# ===========================================================================

def create_prediction_batch(engine) -> int:
    """Insert a prediction_batches row and return its id."""
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    sql = text("""
        INSERT INTO prediction_batches (prediction_date, prediction_time, model_version, created_at)
        VALUES (:pd, :pt, :mv, :ca)
        RETURNING id
    """)
    with engine.begin() as conn:
        row = conn.execute(sql, {
            "pd": now.date(),
            "pt": now.time().replace(microsecond=0),
            "mv": "lightgbm_v1",
            "ca": now,
        })
        batch_id = row.scalar_one()
    log.info("Created prediction batch id=%d", batch_id)
    return batch_id


def delete_todays_batches(engine):
    """Remove any existing batches (and their predictions) for today."""
    with engine.begin() as conn:
        batch_ids = conn.execute(
            text("SELECT id FROM prediction_batches WHERE prediction_date = :d"),
            {"d": date.today()}
        ).scalars().all()

        if not batch_ids:
            log.info("No existing batch(es) for today to delete.")
            return

        conn.execute(
            text("DELETE FROM commodity_predictions WHERE batch_id = ANY(:ids)"),
            {"ids": list(batch_ids)}
        )

        result = conn.execute(
            text("DELETE FROM prediction_batches WHERE id = ANY(:ids)"),
            {"ids": list(batch_ids)}
        )

    log.info("Deleted %d old batch(es) for today.", result.rowcount)


def write_predictions(engine, batch_id: int, records: list[dict]):
    """Bulk-insert prediction rows."""
    if not records:
        return
    sql = text("""
        INSERT INTO commodity_predictions
            (batch_id, market_id, commodity_id, variety_id, grade_id,
             prediction_day, predicted_price, created_at)
        VALUES
            (:batch_id, :market_id, :commodity_id, :variety_id, :grade_id,
             :prediction_day, :predicted_price, :created_at)
    """)
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    rows = [{**r, "batch_id": batch_id, "created_at": now} for r in records]
    with engine.begin() as conn:
        conn.execute(sql, rows)
    log.info("Inserted %d prediction rows.", len(rows))


# ===========================================================================
# Main pipeline
# ===========================================================================

def run(n_days: int = 7, dry_run: bool = False, start_from_today: bool = True):
    log.info("=== Mandi Price Prediction Pipeline ===")
    log.info("Prediction horizon: %d days | dry_run=%s | start_from_today=%s", n_days, dry_run, start_from_today)

    # 1. Load model & feature list
    feature_cols = get_feature_columns(FEATURES_PATH)
    model        = load_model(MODEL_PATH)

    # 2. Connect to DB and fetch data
    engine = get_engine()
    df_raw = fetch_historical_data(engine)
    id_map = fetch_id_map(engine)

    if df_raw.empty:
        log.warning("No historical data found. Exiting.")
        return

    # 3. Identify valid groups (at least 7 records)
    group_counts = df_raw.groupby(GROUPING_COLS).size()
    valid_groups = set(group_counts[group_counts >= MIN_RECORDS].index)

    log.info(
        "Groups with >= %d records: %d / %d total groups",
        MIN_RECORDS, len(valid_groups), len(group_counts)
    )

    # 4. Predict per valid group
    all_prediction_rows = []
    skipped = 0

    for keys, group_df in df_raw.groupby(GROUPING_COLS):
        if keys not in valid_groups:
            skipped += 1
            continue

        state, district, market, cmdt, variety, grade = keys
        id_key = (cmdt, market, variety, grade, state, district)
        ids = id_map.get(id_key)

        if ids is None:
            log.debug("ID lookup miss for %s – skipping.", id_key)
            skipped += 1
            continue

        commodity_id, market_id, variety_id, grade_id = ids

        try:
            forecasts = predict_next_n_days(
                group_df, model, feature_cols,
                n_days=n_days, start_from_today=start_from_today
            )
        except Exception as exc:
            log.warning("Prediction failed for %s: %s", id_key, exc)
            skipped += 1
            continue

        for pred_date, pred_price in forecasts:
            all_prediction_rows.append({
                "commodity_id":    commodity_id,
                "market_id":       market_id,
                "variety_id":      variety_id,
                "grade_id":        grade_id,
                "prediction_day":  pred_date,
                "predicted_price": pred_price,
            })

    log.info(
        "Generated %d prediction rows across %d active groups (%d groups skipped).",
        len(all_prediction_rows), len(valid_groups), skipped
    )

    # 5. Write to DB (unless dry_run)
    if dry_run:
        sample_df = pd.DataFrame(all_prediction_rows).head(14)
        log.info("[DRY RUN] First 14 rows:\n%s", sample_df.to_string(index=False))
        return

    if not all_prediction_rows:
        log.warning("Nothing to write. Exiting.")
        return

    delete_todays_batches(engine)
    batch_id = create_prediction_batch(engine)
    write_predictions(engine, batch_id, all_prediction_rows)

    log.info("=== Pipeline complete ===")


# ===========================================================================
# CLI entry-point
# ===========================================================================

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run Mandi Price Predictions")
    parser.add_argument("--days", type=int, default=7,
                        help="Number of future days to predict (default: 7)")
    parser.add_argument("--dry-run", action="store_true",
                        help="Skip DB writes, print sample output only")
    parser.add_argument("--no-today", action="store_true",
                        help="Do not align start date to date.today(), use last_arrival_date + 1")
    args = parser.parse_args()

    run(n_days=args.days, dry_run=args.dry_run, start_from_today=not args.no_today)
