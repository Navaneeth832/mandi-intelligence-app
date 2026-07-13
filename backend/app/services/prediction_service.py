from datetime import date
from sqlalchemy.orm import Session
from app.models.user import User
from app.repositories.prediction_repository import (
    get_latest_batch,
    get_predictions_with_details,
    get_average_modal_prices,
)
from app.utils.prediction_localization import translate_trend, translate_recommendation

def compute_trend(first_price: float, last_price: float) -> str:
    """Determine trend: last > first -> RISING, last < first -> FALLING, else STABLE"""
    if last_price > first_price:
        return "RISING"
    elif last_price < first_price:
        return "FALLING"
    return "STABLE"

def compute_recommendation(best_sell_date: date, trend: str, today: date) -> str:
    """
    Determine recommendation:
    If best selling day == today -> SELL TODAY
    Else if trend == RISING -> WAIT
    Else if trend == FALLING -> SELL TODAY
    Else -> HOLD
    """
    if best_sell_date == today:
        return "SELL TODAY"
    elif trend == "RISING":
        return "WAIT"
    elif trend == "FALLING":
        return "SELL TODAY"
    return "HOLD"

def get_predictions_for_user(db: Session, current_user: User, language: str) -> list[dict]:
    """
    Retrieve and process predictions for the user's preferred crops.
    """
    # 1. Load user's preferred crop IDs
    commodity_ids = [pref.commodity_id for pref in current_user.crop_preferences]
    if not commodity_ids:
        return []
    
    # Limit to maximum 5 preferred crops
    commodity_ids = commodity_ids[:5]

    # 2. Find today's latest prediction batch
    batch = get_latest_batch(db)
    if not batch:
        return []

    # 3. Load every prediction row belonging to that batch for specified crop IDs
    prediction_rows = get_predictions_with_details(db, batch.id, commodity_ids)
    if not prediction_rows:
        return []

    # 4. Obtain today's current average modal prices
    avg_price_map = get_average_modal_prices(db, commodity_ids)

    # 5. Group predictions by commodity_id (rows are chronologically sorted)
    grouped_predictions = {}
    for row in prediction_rows:
        cid = row.commodity_id
        if cid not in grouped_predictions:
            grouped_predictions[cid] = []
        grouped_predictions[cid].append(row)

    today_val = date.today()
    today_str = today_val.strftime('%Y-%m-%d')
    
    batch_date_str = batch.prediction_date.strftime('%Y-%m-%d')
    try:
        batch_time_str = batch.prediction_time.strftime('%I:%M %p')
    except Exception:
        batch_time_str = str(batch.prediction_time)

    forecasts = []

    for cid, pred_list in grouped_predictions.items():
        if not pred_list:
            continue

        first_row = pred_list[0]
        commodity = first_row.commodity
        
        # Localize crop name via commodity translations table
        commodity_name = commodity.name
        if commodity.translations:
            for translation in commodity.translations:
                if translation.language_code == language:
                    commodity_name = translation.translated_name
                    break

        # Compute prices
        prices = [float(p.predicted_price) for p in pred_list]
        first_price = prices[0]
        last_price = prices[-1]

        # Calculate metrics using business logic helpers
        trend_raw = compute_trend(first_price, last_price)
        expected_peak = max(prices)
        peak_index = prices.index(expected_peak)
        
        best_sell_date_obj = pred_list[peak_index].prediction_day
        best_sell_date_str = best_sell_date_obj.strftime('%Y-%m-%d')

        recommendation_raw = compute_recommendation(best_sell_date_obj, trend_raw, today_val)

        # Localize Trend & Recommendation values
        localized_trend = translate_trend(trend_raw, language)
        localized_recommendation = translate_recommendation(recommendation_raw, language)

        # Map daily forecasts
        forecast_list = [
            {
                "date": p.prediction_day.strftime('%Y-%m-%d'),
                "price": float(p.predicted_price)
            }
            for p in pred_list
        ]

        forecasts.append({
            "commodity_id": cid,
            "commodity_name": commodity_name,
            "prediction_date": batch_date_str,
            "prediction_time": batch_time_str,
            "current_price": avg_price_map.get(cid, 0.0),
            "forecast": forecast_list,
            "trend": localized_trend,
            "recommendation": localized_recommendation,
            "best_sell_date": best_sell_date_str,
            "expected_peak_price": expected_peak
        })

    return forecasts
