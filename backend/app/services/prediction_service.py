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
    market_ids: list[int] | None = None
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
        market_ids=market_ids
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
            "current_price": price_map.get(key, 0.0),
            "forecast": forecast_list,
            "trend": localized_trend,
            "recommendation": localized_recommendation,
            "best_sell_date": best_sell_date_str,
            "expected_peak_price": expected_peak
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

        prices = [float(p.predicted_price) for p in pred_list]
        first_price = prices[0]
        last_price = prices[-1]

        trend_raw = compute_trend(first_price, last_price)
        expected_peak = max(prices)
        peak_index = prices.index(expected_peak)

        best_sell_date_obj = pred_list[peak_index].prediction_day
        recommendation_raw = compute_recommendation(best_sell_date_obj, trend_raw, today_val)

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
            "current_price": price_map.get(key, 0.0),
            "trend": translate_trend(trend_raw, language),
            "recommendation": translate_recommendation(recommendation_raw, language)
        })

    best_markets_list.sort(key=lambda x: x["predicted_price"], reverse=True)
    return best_markets_list
