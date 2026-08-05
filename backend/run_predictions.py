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
import time
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
    log.info("Fetching historical price data from DB...")
    t0 = time.time()
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

    log.info("Fetched %d price rows from DB in %.2f seconds.", len(df), time.time() - t0)
    df["arrival_date"] = pd.to_datetime(df["arrival_date"])
    return df


def fetch_id_map(engine):
    """
    Build lookup maps: (commodity_id, market_id, variety_id, grade_id)
    keyed on the canonical string names used in the feature DataFrame.
    """
    t0 = time.time()
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
    log.info("Built ID map with %d entries in %.2f seconds.", len(id_map), time.time() - t0)
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
# Iterative multi-step prediction (Single Group Helper)
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
    """
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
    sample_row = group_sorted.iloc[-1]
    group_meta = {col: sample_row[col] for col in CATEGORICAL_FEATURES}

    for i in range(n_days):
        target_date = base_start_date + timedelta(days=i)

        dt_year = target_date.year
        dt_month = target_date.month
        dt_dow = target_date.weekday()
        dt_doy = target_date.timetuple().tm_yday
        dt_quarter = (dt_month - 1) // 3 + 1

        month_sin = np.sin(2 * np.pi * dt_month / 12.0)
        month_cos = np.cos(2 * np.pi * dt_month / 12.0)

        lag_1 = float(prices_history[-1])
        lag_3 = float(prices_history[-3]) if len(prices_history) >= 3 else lag_1
        lag_7 = float(prices_history[-7]) if len(prices_history) >= 7 else lag_1

        ma7 = float(np.mean(prices_history[-7:])) if len(prices_history) >= 7 else float(np.mean(prices_history))
        ma30 = float(np.mean(prices_history[-30:])) if len(prices_history) >= 30 else float(np.mean(prices_history))

        alpha_vol = stats["alpha_volatility"]
        month_mean = stats["monthly_means"].get(dt_month, stats["overall_mean"])
        seasonal_index = month_mean / stats["overall_mean"] if stats["overall_mean"] > 0 else 1.0

        pct = ((lag_1 - ma30) / ma30) * 100 if ma30 > 0 else 0.0
        if (ma7 > ma30) and (lag_1 > ma7) and (pct > alpha_vol):
            trend_state = "Rising"
        elif (ma7 < ma30) and (lag_1 < ma7) and (pct < -alpha_vol):
            trend_state = "Falling"
        else:
            trend_state = "Stable"

        trend_state_encoded = TREND_MAPPING.get(trend_state, 1)

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
        for col in CATEGORICAL_FEATURES:
            row_df[col] = row_df[col].astype("category")

        X = row_df[feature_cols]
        pred_price = float(model.predict(X, num_iteration=model.best_iteration)[0])
        pred_price = max(pred_price, 0.0)

        results.append((target_date, round(pred_price, 2)))
        prices_history.append(pred_price)

    return results


# ===========================================================================
# Batched Multi-Group Prediction Engine (High-Performance Vectorized)
# ===========================================================================

def predict_all_groups_batched(
    df_raw: pd.DataFrame,
    id_map: dict,
    model: lgb.Booster,
    feature_cols: list[str],
    n_days: int = 7,
    start_from_today: bool = True
) -> tuple[list[dict], int]:
    """
    High-Performance Batched Predictor across all active commodity groups.
    Vectorizes feature creation and batch runs LightGBM model.predict() in
    7 total batch calls instead of 50,000+ single-row calls.
    """
    start_time = time.time()
    today_val = date.today()

    log.info("Grouping raw data and preparing active group states...")
    grouped = df_raw.groupby(GROUPING_COLS)
    total_groups = len(grouped)

    active_states = []
    skipped = 0

    for keys, group_df in grouped:
        if len(group_df) < MIN_RECORDS:
            skipped += 1
            continue

        state_name, district_name, market_name, cmdt_name, variety_name, grade_name = keys
        id_key = (cmdt_name, market_name, variety_name, grade_name, state_name, district_name)
        ids = id_map.get(id_key)

        if ids is None:
            skipped += 1
            continue

        commodity_id, market_id, variety_id, grade_id = ids

        group_sorted = group_df.sort_values("arrival_date").reset_index(drop=True)
        prices_history = list(group_sorted["model_price"].values)
        
        last_arrival = group_sorted["arrival_date"].iloc[-1].date()
        if start_from_today and last_arrival < today_val:
            base_start_date = today_val + timedelta(days=1)
        else:
            base_start_date = last_arrival + timedelta(days=1)

        stats = compute_group_historical_stats(group_sorted)

        active_states.append({
            "group_meta": {
                "state_name": state_name,
                "district_name": district_name,
                "market_name": market_name,
                "cmdt_name": cmdt_name,
                "grade_name": grade_name,
                "variety_name": variety_name,
            },
            "ids": {
                "commodity_id": commodity_id,
                "market_id": market_id,
                "variety_id": variety_id,
                "grade_id": grade_id,
            },
            "prices_history": prices_history,
            "stats": stats,
            "base_start_date": base_start_date,
        })

    log.info(
        "Prepared metadata and stats for %d active groups (%d / %d skipped) in %.2f seconds.",
        len(active_states), skipped, total_groups, time.time() - start_time
    )

    if not active_states:
        return [], skipped

    all_prediction_rows = []

    # Iterative Day-by-Day Batch Predictions
    for day_idx in range(n_days):
        t_day_start = time.time()
        batch_rows = []

        for state in active_states:
            group_meta = state["group_meta"]
            prices_history = state["prices_history"]
            stats = state["stats"]
            target_date = state["base_start_date"] + timedelta(days=day_idx)

            dt_year = target_date.year
            dt_month = target_date.month
            dt_dow = target_date.weekday()
            dt_doy = target_date.timetuple().tm_yday
            dt_quarter = (dt_month - 1) // 3 + 1

            month_sin = np.sin(2 * np.pi * dt_month / 12.0)
            month_cos = np.cos(2 * np.pi * dt_month / 12.0)

            lag_1 = float(prices_history[-1])
            lag_3 = float(prices_history[-3]) if len(prices_history) >= 3 else lag_1
            lag_7 = float(prices_history[-7]) if len(prices_history) >= 7 else lag_1

            ma7 = float(np.mean(prices_history[-7:])) if len(prices_history) >= 7 else float(np.mean(prices_history))
            ma30 = float(np.mean(prices_history[-30:])) if len(prices_history) >= 30 else float(np.mean(prices_history))

            alpha_vol = stats["alpha_volatility"]
            month_mean = stats["monthly_means"].get(dt_month, stats["overall_mean"])
            seasonal_index = month_mean / stats["overall_mean"] if stats["overall_mean"] > 0 else 1.0

            pct = ((lag_1 - ma30) / ma30) * 100 if ma30 > 0 else 0.0
            if (ma7 > ma30) and (lag_1 > ma7) and (pct > alpha_vol):
                trend_state = "Rising"
            elif (ma7 < ma30) and (lag_1 < ma7) and (pct < -alpha_vol):
                trend_state = "Falling"
            else:
                trend_state = "Stable"

            trend_state_encoded = TREND_MAPPING.get(trend_state, 1)

            batch_rows.append({
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
                "trend_state_encoded": trend_state_encoded,
                "target_date": target_date,
            })

        batch_df = pd.DataFrame(batch_rows)
        for col in CATEGORICAL_FEATURES:
            batch_df[col] = batch_df[col].astype("category")

        X = batch_df[feature_cols]

        preds = model.predict(X, num_iteration=model.best_iteration)
        preds = np.maximum(preds, 0.0)

        for state, target_date, pred_price in zip(active_states, batch_df["target_date"], preds):
            rounded_price = round(float(pred_price), 2)
            state["prices_history"].append(rounded_price)

            all_prediction_rows.append({
                "commodity_id": state["ids"]["commodity_id"],
                "market_id": state["ids"]["market_id"],
                "variety_id": state["ids"]["variety_id"],
                "grade_id": state["ids"]["grade_id"],
                "prediction_day": target_date,
                "predicted_price": rounded_price,
            })

        log.info(
            "Day %d/%d batch predictions completed (%d rows) in %.2f seconds.",
            day_idx + 1, n_days, len(active_states), time.time() - t_day_start
        )

    total_elapsed = time.time() - start_time
    log.info(
        "Generated %d total prediction rows across %d active groups in %.2f seconds.",
        len(all_prediction_rows), len(active_states), total_elapsed
    )

    return all_prediction_rows, skipped


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


def write_predictions(engine, batch_id: int, records: list[dict], chunk_size: int = 3000):
    """Bulk-insert prediction rows using high-speed multi-row inserts."""
    if not records:
        return
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    for r in records:
        r["batch_id"] = batch_id
        r["created_at"] = now

    df_preds = pd.DataFrame(records)

    log.info("Writing %d prediction rows to DB in multi-value chunks of %d...", len(df_preds), chunk_size)
    t0 = time.time()
    
    df_preds.to_sql(
        name="commodity_predictions",
        con=engine,
        if_exists="append",
        index=False,
        method="multi",
        chunksize=chunk_size
    )

    log.info("Inserted %d prediction rows into DB in %.2f seconds.", len(df_preds), time.time() - t0)


# ===========================================================================
# Main pipeline
# ===========================================================================

def run(n_days: int = 7, dry_run: bool = False, start_from_today: bool = True):
    log.info("=== Mandi Price Prediction Pipeline ===")
    log.info("Prediction horizon: %d days | dry_run=%s | start_from_today=%s", n_days, dry_run, start_from_today)

    t_start = time.time()

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

    # 3. High-Performance Batched Predictions
    all_prediction_rows, skipped = predict_all_groups_batched(
        df_raw=df_raw,
        id_map=id_map,
        model=model,
        feature_cols=feature_cols,
        n_days=n_days,
        start_from_today=start_from_today
    )

    # 4. Write to DB (unless dry_run)
    if dry_run:
        sample_df = pd.DataFrame(all_prediction_rows).head(14)
        log.info("[DRY RUN] First 14 rows:\n%s", sample_df.to_string(index=False))
        log.info("=== Pipeline dry run complete in %.2f seconds ===", time.time() - t_start)
        return

    if not all_prediction_rows:
        log.warning("Nothing to write. Exiting.")
        return

    delete_todays_batches(engine)
    batch_id = create_prediction_batch(engine)
    write_predictions(engine, batch_id, all_prediction_rows)

    log.info("=== Pipeline complete in %.2f seconds ===", time.time() - t_start)


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
