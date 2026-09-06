from datetime import date
from sqlalchemy.orm import Session
from app.models.user import User
from app.repositories.prediction_repository import (
    get_latest_batch,
    get_predictions_with_details,
    get_latest_mandi_prices_for_combinations,
)
from app.utils.prediction_localization import translate_trend, translate_recommendation

def get_translated_name(language_code: str, entity) -> str | None:
    """Helper function to get translated name from any entity with translations"""
    if entity.translations:
        for translation in entity.translations:
            if translation.language_code == language_code:
                return translation.translated_name
    return None

def compute_trend(first_price: float, last_price: float) -> str:
    """
    Determine trend using first vs last price with +/- 2% tolerance:
    change_pct >= +2%  -> RISING
    change_pct <= -2%  -> FALLING
    otherwise           -> STABLE
    """
    if first_price <= 0:
        return "STABLE"
    change_pct = ((last_price - first_price) / first_price) * 100.0
    if change_pct >= 2.0:
        return "RISING"
    elif change_pct <= -2.0:
        return "FALLING"
    return "STABLE"

def compute_expected_upside(expected_peak_price: float, current_price: float) -> float:
    """
    upside_pct = (expected_peak_price - current_price) / current_price * 100
    """
    if current_price <= 0:
        return 0.0
    return round(((expected_peak_price - current_price) / current_price) * 100.0, 2)

def compute_selling_window(pred_list: list, expected_peak_price: float) -> list[str]:
    """
    Selling window = forecast days whose price is within 2% of predicted peak:
    price >= expected_peak_price * 0.98
    """
    threshold = expected_peak_price * 0.98
    window = []
    for p in pred_list:
        if float(p.predicted_price) >= threshold:
            window.append(p.prediction_day.strftime('%Y-%m-%d'))
    return window

def evaluate_data_quality(pred_list: list, current_price: float) -> tuple[str, bool]:
    """
    Evaluates forecast data quality:
    Returns (data_quality_label, is_valid)
    """
    if not pred_list or len(pred_list) < 3 or current_price <= 0:
        return "LOW", False

    prices = [float(p.predicted_price) for p in pred_list]
    if any(p <= 0 for p in prices):
        return "LOW", False

    # Volatility check: standard deviation / mean
    mean_val = sum(prices) / len(prices)
    if mean_val > 0:
        variance = sum((x - mean_val) ** 2 for x in prices) / len(prices)
        std_dev = variance ** 0.5
        cv = std_dev / mean_val
        if cv > 0.4:
            return "VOLATILE", False

    return "HIGH", True

def compute_recommendation(
    best_sell_date_obj: date,
    selling_window_dates: list[date],
    trend: str,
    expected_upside_pct: float,
    current_price: float,
    expected_peak_price: float,
    is_data_valid: bool,
    today: date
) -> str:
    """
    Production recommendation matrix:
    - ⚪ NO CLEAR SIGNAL: incomplete data, volatile forecast, or stale/missing current_price
    - 🟢 WAIT: expected_upside_pct > 2% AND selling_window occurs in future AND trend == RISING
    - 🟡 HOLD: abs(expected_upside_pct) <= 2% AND trend == STABLE
    - 🔴 SELL TODAY: current_price >= expected_peak_price * 0.98 OR (trend == FALLING and expected_upside_pct <= 2%)
    """
    if not is_data_valid:
        return "NO CLEAR SIGNAL"

    # 1. 🟢 WAIT
    has_future_window = any(d > today for d in selling_window_dates)
    if trend == "RISING" and expected_upside_pct > 2.0 and has_future_window:
        return "WAIT"

    # 2. 🟡 HOLD
    if trend == "STABLE" and abs(expected_upside_pct) <= 2.0:
        return "HOLD"

    # 3. 🔴 SELL TODAY
    if current_price >= (expected_peak_price * 0.98):
        return "SELL TODAY"
    if trend == "FALLING" and expected_upside_pct <= 2.0:
        return "SELL TODAY"

    # 4. ⚪ Fallback / No clear signal
    return "NO CLEAR SIGNAL"



from app.api.routes.mandi_prices import get_commodity_image_url

def get_predictions_for_user(
    db: Session,
    current_user: User,
    language: str,
    page: int = 1,
    page_size: int = 15,
    commodity_id: int | None = None,
    market_id: int | None = None,
    commodity_ids: list[int] | None = None,
    market_ids: list[int] | None = None,
    district_id: int | None = None
) -> dict:
    """
    Retrieve and process predictions, paginated and sorted.
    If commodity_ids or commodity_id is explicitly specified, queries predictions for those commodities.
    """
    # 1. Load crop IDs (override with commodity_ids / commodity_id if provided)
    if commodity_ids is not None and len(commodity_ids) > 0:
        target_commodity_ids = commodity_ids
    elif commodity_id is not None:
        target_commodity_ids = [commodity_id]
    else:
        target_commodity_ids = [pref.commodity_id for pref in current_user.crop_preferences]
        if not target_commodity_ids:
            return {
                "page": page,
                "page_size": page_size,
                "total": 0,
                "has_next": False,
                "predictions": []
            }
        target_commodity_ids = target_commodity_ids[:5]

    # 2. Find today's latest prediction batch
    batch = get_latest_batch(db)
    if not batch:
        return {
            "page": page,
            "page_size": page_size,
            "total": 0,
            "has_next": False,
            "predictions": []
        }

    # 3. Load paginated prediction details from repository
    from app.repositories.prediction_repository import get_predictions_with_details_paginated
    prediction_rows, paginated_combos, total = get_predictions_with_details_paginated(
        db,
        batch.id,
        target_commodity_ids,
        page=page,
        page_size=page_size,
        commodity_id=commodity_id,
        market_id=market_id,
        market_ids=market_ids,
        district_id=district_id
    )
    if not prediction_rows:
        return {
            "page": page,
            "page_size": page_size,
            "total": total,
            "has_next": False,
            "predictions": []
        }

    # 4. Group predictions by (commodity_id, market_id, variety_id, grade_id)
    grouped_predictions = {}
    for row in prediction_rows:
        key = (row.commodity_id, row.market_id, row.variety_id, row.grade_id)
        if key not in grouped_predictions:
            grouped_predictions[key] = []
        grouped_predictions[key].append(row)

    # 5. Obtain today's current prices matching the exact combinations
    price_map = get_latest_mandi_prices_for_combinations(db, list(grouped_predictions.keys()))

    today_val = date.today()
    
    batch_date_str = batch.prediction_date.strftime('%Y-%m-%d')
    try:
        batch_time_str = batch.prediction_time.strftime('%I:%M %p')
    except Exception:
        batch_time_str = str(batch.prediction_time)

    predictions_list = []

    # 6. Process combinations in the exact order returned by the paginated distinct query
    for key in paginated_combos:
        pred_list = grouped_predictions.get(key)
        if not pred_list:
            continue

        first_row = pred_list[0]
        
        # Localize crop name via commodity translations table
        commodity_name = get_translated_name(language, first_row.commodity) or first_row.commodity.name
        market_name = get_translated_name(language, first_row.market) or first_row.market.name
        district_name = get_translated_name(language, first_row.market.district) or first_row.market.district.name
        state_name = get_translated_name(language, first_row.market.district.state) or first_row.market.district.state.name
        
        # Variety and Grade names do not have translation tables, use raw names
        variety_name = first_row.variety.name
        grade_name = first_row.grade.grade_name

        # Compute current price and data metrics
        curr_price_val = price_map.get(key, 0.0)

        prices = [float(p.predicted_price) for p in pred_list]
        first_price = prices[0]
        last_price = prices[-1]

# Calculate metrics using business logic helpers
        trend_raw = compute_trend(first_price, last_price)
        expected_peak_forecast = max(prices)

        # 1. Identify the actual peak date from the data
        if curr_price_val > expected_peak_forecast:
            expected_peak = curr_price_val
            forecast_peak_date_obj = today_val
        else:
            expected_peak = expected_peak_forecast
            peak_index = prices.index(expected_peak)
            forecast_peak_date_obj = pred_list[peak_index].prediction_day

        selling_window_str_list = compute_selling_window(pred_list, expected_peak)
        selling_window_dates = [p.prediction_day for p in pred_list if float(p.predicted_price) >= expected_peak * 0.98]
        
        if curr_price_val >= expected_peak * 0.98:
            today_str = today_val.strftime('%Y-%m-%d')
            if today_str not in selling_window_str_list:
                selling_window_str_list.insert(0, today_str)
            if today_val not in selling_window_dates:
                selling_window_dates.insert(0, today_val)

        expected_upside_pct = compute_expected_upside(expected_peak, curr_price_val)
        data_quality_label, is_data_valid = evaluate_data_quality(pred_list, curr_price_val)

        # 2. Compute the recommendation using the forecasted peak date
        recommendation_raw = compute_recommendation(
            forecast_peak_date_obj,
            selling_window_dates,
            trend_raw,
            expected_upside_pct,
            curr_price_val,
            expected_peak,
            is_data_valid,
            today_val
        )

        # 3. NEW LOGIC: Determine the UI display date based on the recommendation
        if recommendation_raw == "SELL TODAY":
            best_sell_date_str = "Today"
        else:
            # For HOLD, WAIT, or NO CLEAR SIGNAL, show the absolute peak price date
            if forecast_peak_date_obj == today_val:
                best_sell_date_str = "Today"
            else:
                best_sell_date_str = forecast_peak_date_obj.strftime('%Y-%m-%d')

        # Localize Trend & Recommendation values
        localized_trend = translate_trend(trend_raw, language)
        localized_recommendation = translate_recommendation(recommendation_raw, language)

        # Map daily forecasts
        forecast_list = []
        if curr_price_val > 0:
            forecast_list.append({
                "date": today_val.strftime('%Y-%m-%d'),
                "price": float(curr_price_val)
            })

        forecast_list.extend([
            {
                "date": p.prediction_day.strftime('%Y-%m-%d'),
                "price": float(p.predicted_price)
            }
            for p in pred_list
        ])

        # Advisory and logistics calculations
        transport_cost = 150.0
        market_fee = 45.0
        base_diff = expected_peak - curr_price_val - transport_cost - market_fee if curr_price_val > 0 else expected_peak * 0.15
        expected_profit = round(max(120.0, base_diff), 2)

        if recommendation_raw == "SELL TODAY":
            # Check specifically if the trend is falling
            if trend_raw == "FALLING":
                ai_title = "Action Required: Downward Trend"
                rec_reason = f"The market trend in {market_name} is falling. Even though a peak of ₹{int(expected_peak)} is forecasted, holding is risky. Selling today minimizes potential losses from further price drops."
            # Otherwise, it triggered because the current price is within 2% of the peak
            else:
                ai_title = "Maximum Price Window Active"
                rec_reason = f"The current price in {market_name} is within 2% of the expected peak (₹{int(expected_peak)}). Selling today secures your profit and protects against unexpected market volatility."
                
        elif recommendation_raw == "WAIT":
            ai_title = "Price Appreciation Expected"
            window_text = f"between {selling_window_str_list[0]} and {selling_window_str_list[-1]}" if len(selling_window_str_list) > 1 else f"on {best_sell_date_str}"
            rec_reason = f"Prices in {market_name} are trending upward with an expected upside of {expected_upside_pct}%, peaking near ₹{int(expected_peak)} {window_text}."
            
        elif recommendation_raw == "HOLD":
            ai_title = "Stable Market Outlook"
            rec_reason = f"Prices remain steady near ₹{int(expected_peak)} with minimal expected upside ({expected_upside_pct}%). Monitor local demand."
            
        else:
            ai_title = "Inconclusive Signal"
            rec_reason = "Market forecast data is incomplete, stale, or volatile. Monitor daily arrivals before scheduling sales."

        predictions_list.append({
            "commodity_id": first_row.commodity_id,
            "commodity_name": commodity_name,
            "commodity_image_url": get_commodity_image_url(first_row.commodity_id),
            "market_id": first_row.market_id,
            "market_name": market_name,
            "district_id": first_row.market.district_id,
            "district_name": district_name,
            "state_id": first_row.market.district.state_id,
            "state_name": state_name,
            "variety_id": first_row.variety_id,
            "variety_name": variety_name,
            "grade_id": first_row.grade_id,
            "grade_name": grade_name,
            "prediction_date": batch_date_str,
            "prediction_time": batch_time_str,
            "current_price": curr_price_val,
            "forecast": forecast_list,
            "trend": localized_trend,
            "recommendation": localized_recommendation,
            "best_sell_date": best_sell_date_str,
            "expected_peak_price": expected_peak,
            "selling_window": selling_window_str_list,
            "expected_upside_pct": expected_upside_pct,
            "data_quality": data_quality_label,
            "transport_cost": transport_cost,
            "market_fee": market_fee,
            "expected_profit": expected_profit,
            "recommendation_reason": rec_reason,
            "ai_recommendation_title": ai_title,
        })

    has_next = (page * page_size) < total

    return {
        "page": page,
        "page_size": page_size,
        "total": total,
        "has_next": has_next,
        "predictions": predictions_list
    }


def get_best_markets_for_commodity(
    db: Session,
    current_user: User,
    commodity_id: int,
    language: str,
    include_all: bool = False
) -> list[dict]:
    """
    Get best markets for a commodity. By default filters strictly in SQL to markets
    in the user's selected district (sorted in descending order of predicted selling price).
    If include_all is True, fetches all markets across India for this commodity.
    """
    batch = get_latest_batch(db)
    if not batch:
        return []

    district_id = current_user.district_id if not include_all else None

    from app.repositories.prediction_repository import get_predictions_with_details
    prediction_rows = get_predictions_with_details(db, batch.id, [commodity_id], district_id=district_id)
    if not prediction_rows:
        return []

    grouped_predictions = {}
    for row in prediction_rows:
        key = (row.commodity_id, row.market_id, row.variety_id, row.grade_id)
        if key not in grouped_predictions:
            grouped_predictions[key] = []
        grouped_predictions[key].append(row)

    price_map = get_latest_mandi_prices_for_combinations(db, list(grouped_predictions.keys()))
    today_val = date.today()

    best_markets_list = []

    for key, pred_list in grouped_predictions.items():
        if not pred_list:
            continue
        first_row = pred_list[0]
        mkt = first_row.market

        market_name = get_translated_name(language, mkt) or mkt.name
        district_name = get_translated_name(language, mkt.district) or mkt.district.name
        state_name = get_translated_name(language, mkt.district.state) or mkt.district.state.name
        variety_name = first_row.variety.name
        grade_name = first_row.grade.grade_name

        curr_price_val = price_map.get(key, 0.0)
        prices = [float(p.predicted_price) for p in pred_list]
        first_price = prices[0]
        last_price = prices[-1]

        trend_raw = compute_trend(first_price, last_price)
        expected_peak_forecast = max(prices)

        if curr_price_val > expected_peak_forecast:
            expected_peak = curr_price_val
            best_sell_date_obj = today_val
        else:
            expected_peak = expected_peak_forecast
            peak_index = prices.index(expected_peak)
            best_sell_date_obj = pred_list[peak_index].prediction_day

        selling_window_dates = [p.prediction_day for p in pred_list if float(p.predicted_price) >= expected_peak * 0.98]
        if curr_price_val >= expected_peak * 0.98:
            if today_val not in selling_window_dates:
                selling_window_dates.insert(0, today_val)

        expected_upside_pct = compute_expected_upside(expected_peak, curr_price_val)
        data_quality_label, is_data_valid = evaluate_data_quality(pred_list, curr_price_val)

        recommendation_raw = compute_recommendation(
            best_sell_date_obj,
            selling_window_dates,
            trend_raw,
            expected_upside_pct,
            curr_price_val,
            expected_peak,
            is_data_valid,
            today_val
        )

        best_markets_list.append({
            "market_id": mkt.id,
            "market_name": market_name,
            "district_id": mkt.district_id,
            "district_name": district_name,
            "state_id": mkt.district.state_id,
            "state_name": state_name,
            "variety_id": first_row.variety_id,
            "variety_name": variety_name,
            "grade_id": first_row.grade_id,
            "grade_name": grade_name,
            "predicted_price": expected_peak,
            "current_price": curr_price_val,
            "trend": translate_trend(trend_raw, language),
            "recommendation": translate_recommendation(recommendation_raw, language)
        })

    best_markets_list.sort(key=lambda x: x["predicted_price"], reverse=True)
    return best_markets_list

