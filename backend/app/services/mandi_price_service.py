from app.repositories.mandi_price_repository import (
    get_price_history,
)


def fetch_price_history(
    db,
    commodity_name: str,
    market_name: str,
    variety_name: str,
):
    data = get_price_history(
        db,
        commodity_name,
        market_name,
        variety_name,
    )

    return list(reversed(data))