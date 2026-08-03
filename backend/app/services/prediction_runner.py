"""
Prediction Runner Service Module
=================================
Exposes programmatic interface to trigger Mandi LightGBM price prediction pipeline.
Can be invoked from scheduled tasks (e.g. APScheduler, background tasks, or cron jobs).
"""

import logging
from sqlalchemy.orm import Session
from run_predictions import run as execute_prediction_run, get_engine

log = logging.getLogger("mandi.predict_runner")

def run_daily_prediction_job(n_days: int = 7, dry_run: bool = False, start_from_today: bool = True):
    """
    Triggers the full commodity price prediction job.
    Called by scheduled tasks or manual admin triggers.
    """
    log.info("Starting scheduled commodity price prediction job...")
    try:
        execute_prediction_run(n_days=n_days, dry_run=dry_run, start_from_today=start_from_today)
        log.info("Scheduled commodity price prediction job completed successfully.")
        return {"status": "success", "message": "Prediction job completed successfully"}
    except Exception as exc:
        log.error("Error executing scheduled prediction job: %s", exc, exc_info=True)
        return {"status": "error", "message": str(exc)}
