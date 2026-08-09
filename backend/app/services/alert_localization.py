from typing import Tuple, Optional
from sqlalchemy.orm import Session
from app.models.commodity import Commodity
from app.models.commodity_translation import CommodityTranslation
from app.models.market import Market
from app.models.market_translation import MarketTranslation
from app.schemas.alert import AlertType

TEMPLATES = {
    "en": {
        f"{AlertType.PRICE_INCREASE.value}_TITLE": "{commodity} price increased",
        f"{AlertType.PRICE_INCREASE.value}_MSG": "{commodity} prices increased by {percent}% in {market}.",
        f"{AlertType.PRICE_DROP.value}_TITLE": "{commodity} price dropped",
        f"{AlertType.PRICE_DROP.value}_MSG": "{commodity} prices dropped by {percent}% in {market}.",
        f"{AlertType.BETTER_MARKET.value}_TITLE": "Better price available",
        f"{AlertType.BETTER_MARKET.value}_MSG": "A better selling opportunity for {commodity} is available at {market}.",
        f"{AlertType.AI_RECOMMENDATION.value}_TITLE": "Selling recommendation",
        f"{AlertType.AI_RECOMMENDATION.value}_MSG": "Prices for {commodity} are expected to shift at {market}. Check the advisory tab.",
    },
    "hi": {
        f"{AlertType.PRICE_INCREASE.value}_TITLE": "{commodity} की कीमत में वृद्धि",
        f"{AlertType.PRICE_INCREASE.value}_MSG": "{market} में {commodity} की कीमत में {percent}% की वृद्धि हुई है।",
        f"{AlertType.PRICE_DROP.value}_TITLE": "{commodity} की कीमत में गिरावट",
        f"{AlertType.PRICE_DROP.value}_MSG": "{market} में {commodity} की कीमत में {percent}% की गिरावट आई है।",
        f"{AlertType.BETTER_MARKET.value}_TITLE": "बेहतर कीमत उपलब्ध",
        f"{AlertType.BETTER_MARKET.value}_MSG": "{market} पर {commodity} के लिए एक बेहतर बिक्री का अवसर उपलब्ध है।",
        f"{AlertType.AI_RECOMMENDATION.value}_TITLE": "बिक्री की सिफारिश",
        f"{AlertType.AI_RECOMMENDATION.value}_MSG": "{market} पर {commodity} की कीमतों में बदलाव की उम्मीद है। एडवाइजरी टैब देखें।",
    },
    "ml": {
        f"{AlertType.PRICE_INCREASE.value}_TITLE": "{commodity} വില വർദ്ധിച്ചു",
        f"{AlertType.PRICE_INCREASE.value}_MSG": "{market}-ൽ {commodity}-യുടെ വില {percent}% വർദ്ധിച്ചു.",
        f"{AlertType.PRICE_DROP.value}_TITLE": "{commodity} വില കുറഞ്ഞു",
        f"{AlertType.PRICE_DROP.value}_MSG": "{market}-ൽ {commodity}-യുടെ വില {percent}% കുറഞ്ഞു.",
        f"{AlertType.BETTER_MARKET.value}_TITLE": "മികച്ച വില ലഭ്യമാണ്",
        f"{AlertType.BETTER_MARKET.value}_MSG": "{market}-ൽ {commodity} വിൽക്കാൻ മികച്ച അവസരമുണ്ട്.",
        f"{AlertType.AI_RECOMMENDATION.value}_TITLE": "വിൽപ്പന നിർദ്ദേശം",
        f"{AlertType.AI_RECOMMENDATION.value}_MSG": "{market}-ൽ {commodity}-യുടെ വില മാറാൻ സാധ്യതയുണ്ട്. അഡ്വൈസറി ടാബ് പരിശോധിക്കുക.",
    }
}

class AlertLocalizationService:
    _commodity_cache = {}
    _market_cache = {}

    @classmethod
    def get_translated_commodity(cls, db: Session, commodity_id: int, lang: str) -> str:
        cache_key = (commodity_id, lang)
        if cache_key in cls._commodity_cache:
            return cls._commodity_cache[cache_key]

        if lang != "en":
            translation = db.query(CommodityTranslation).filter(
                CommodityTranslation.commodity_id == commodity_id,
                CommodityTranslation.language_code == lang
            ).first()
            if translation and translation.translated_name:
                cls._commodity_cache[cache_key] = translation.translated_name
                return translation.translated_name
        
        commodity = db.query(Commodity).filter(Commodity.id == commodity_id).first()
        name = commodity.name if commodity else f"Commodity #{commodity_id}"
        cls._commodity_cache[cache_key] = name
        return name

    @classmethod
    def get_translated_market(cls, db: Session, market_id: int, lang: str) -> str:
        cache_key = (market_id, lang)
        if cache_key in cls._market_cache:
            return cls._market_cache[cache_key]

        if lang != "en":
            translation = db.query(MarketTranslation).filter(
                MarketTranslation.market_id == market_id,
                MarketTranslation.language_code == lang
            ).first()
            if translation and translation.translated_name:
                cls._market_cache[cache_key] = translation.translated_name
                return translation.translated_name
        
        market = db.query(Market).filter(Market.id == market_id).first()
        name = market.name if market else f"Market #{market_id}"
        cls._market_cache[cache_key] = name
        return name

    @classmethod
    def build_localized_alert(
        cls,
        db: Session,
        user_lang: str,
        alert_type: AlertType,
        commodity_id: int,
        market_id: int,
        price_change: Optional[float] = None
    ) -> Tuple[str, str]:
        """
        Returns a tuple of (title, message) properly localized.
        """
        if user_lang not in TEMPLATES:
            user_lang = "en"
            
        commodity_name = cls.get_translated_commodity(db, commodity_id, user_lang)
        market_name = cls.get_translated_market(db, market_id, user_lang)
        
        # Round the percent for clean display
        percent_str = f"{abs(price_change):.1f}" if price_change is not None else ""
        
        type_str = alert_type.value if hasattr(alert_type, "value") else str(alert_type)
        
        title_template = TEMPLATES[user_lang].get(f"{type_str}_TITLE", "Alert")
        msg_template = TEMPLATES[user_lang].get(f"{type_str}_MSG", "You have a new alert.")
        
        title = title_template.format(commodity=commodity_name, market=market_name, percent=percent_str)
        message = msg_template.format(commodity=commodity_name, market=market_name, percent=percent_str)
        
        return title, message
