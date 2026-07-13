# Translation dictionaries for predictions (Trend & Recommendation)
# Supported languages: en (English), hi (Hindi), ml (Malayalam)
TRANSLATIONS = {
    "trend": {
        "RISING": {
            "en": "Rising",
            "hi": "बढ़ रहा है",
            "ml": "വർധിക്കുന്നു",
        },
        "FALLING": {
            "en": "Falling",
            "hi": "गिर रहा है",
            "ml": "കുറയുന്നു",
        },
        "STABLE": {
            "en": "Stable",
            "hi": "स्थिर",
            "ml": "സ്ഥിരമാണ്",
        }
    },
    "recommendation": {
        "WAIT": {
            "en": "Wait",
            "hi": "प्रतीक्षा करें",
            "ml": "കാത്തിരിക്കുക",
        },
        "SELL TODAY": {
            "en": "Sell Today",
            "hi": "आज बेचें",
            "ml": "ഇന്ന് വിൽക്കുക",
        },
        "HOLD": {
            "en": "Hold",
            "hi": "रोक कर रखें",
            "ml": "കൈവശം വയ്ക്കുക",
        }
    }
}

def translate_trend(trend_value: str, language: str) -> str:
    """Translate internal trend value (e.g. RISING) to localized display string."""
    lang = (language or "en").lower()
    val = (trend_value or "").upper()
    
    # Check exact match
    if val in TRANSLATIONS["trend"]:
        return TRANSLATIONS["trend"][val].get(lang, TRANSLATIONS["trend"][val].get("en", trend_value))
    return trend_value

def translate_recommendation(recommendation_value: str, language: str) -> str:
    """Translate internal recommendation value (e.g. WAIT) to localized display string."""
    lang = (language or "en").lower()
    val = (recommendation_value or "").upper()
    
    if val in TRANSLATIONS["recommendation"]:
        return TRANSLATIONS["recommendation"][val].get(lang, TRANSLATIONS["recommendation"][val].get("en", recommendation_value))
    return recommendation_value
