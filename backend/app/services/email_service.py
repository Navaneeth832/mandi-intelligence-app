import logging
import resend
from app.core.config import settings

logger = logging.getLogger(__name__)

if hasattr(settings, "RESEND_API_KEY") and settings.RESEND_API_KEY:
    resend.api_key = settings.RESEND_API_KEY

ALERT_TEMPLATES = {
    "en": {
        "PRICE_INCREASE": {
            "subject": "🌾 Mandi Alert: {commodity} price increased",
            "type_label": "Price Increased",
            "badge_color": "#16A34A",
            "badge_bg": "#DCFCE7",
            "recommendation_default": "Consider selling your crop now while prices are high.",
        },
        "PRICE_DROP": {
            "subject": "📉 Mandi Alert: {commodity} price dropped",
            "type_label": "Price Decreased",
            "badge_color": "#DC2626",
            "badge_bg": "#FEE2E2",
            "recommendation_default": "Consider holding stock until market prices recover.",
        },
        "MARKET_GLUT": {
            "subject": "⚠️ Mandi Alert: Heavy supply of {commodity} detected",
            "type_label": "Market Glut Detected",
            "badge_color": "#EA580C",
            "badge_bg": "#FFEDD5",
            "recommendation_default": "High arrival volume detected. Explore alternative nearby mandis for better returns.",
        },
        "SELLING_OPPORTUNITY": {
            "subject": "💰 Mandi Alert: Recommended Selling Opportunity for {commodity}",
            "type_label": "Recommended Selling Opportunity",
            "badge_color": "#0284C7",
            "badge_bg": "#E0F2FE",
            "recommendation_default": "Current prices are favorable. Great window to bring your harvest to market.",
        },
        "BETTER_MARKET": {
            "subject": "🏪 Mandi Alert: Better Market Available for {commodity}",
            "type_label": "Better Market Available",
            "badge_color": "#7C3AED",
            "badge_bg": "#F3E8FF",
            "recommendation_default": "Higher prices recorded in a neighboring mandi. Compare markets before selling.",
        },
        "AI_RECOMMENDATION": {
            "subject": "🤖 Mandi Alert: Market Advisory for {commodity}",
            "type_label": "Market Advisory",
            "badge_color": "#059669",
            "badge_bg": "#D1FAE5",
            "recommendation_default": "Based on market trends and price forecasts, plan your harvest dispatch accordingly.",
        },
        "greeting": "Hello",
        "update_intro": "We have an important mandi update for you.",
        "current_price_label": "Current Price",
        "previous_price_label": "Previous Price",
        "change_label": "Price Shift",
        "recommendation_label": "Recommendation",
        "footer_cta": "Open the Mandi Intelligence app to view complete market insights and 7-day price forecasts.",
        "regards": "Regards,",
        "team_name": "Mandi Intelligence Team",
        "unit": "/ quintal",
    },
    "hi": {
        "PRICE_INCREASE": {
            "subject": "🌾 मंडी अलर्ट: {commodity} की कीमत बढ़ी",
            "type_label": "कीमत बढ़ी",
            "badge_color": "#16A34A",
            "badge_bg": "#DCFCE7",
            "recommendation_default": "कीमतें ऊंची होने के दौरान अपनी फसल बेचने पर विचार करें।",
        },
        "PRICE_DROP": {
            "subject": "📉 मंडी अलर्ट: {commodity} की कीमत घटी",
            "type_label": "कीमत घटी",
            "badge_color": "#DC2626",
            "badge_bg": "#FEE2E2",
            "recommendation_default": "बाजार भाव में सुधार होने तक अपनी उपज को रोककर रखने पर विचार करें।",
        },
        "MARKET_GLUT": {
            "subject": "⚠️ मंडी अलर्ट: {commodity} की अत्यधिक आवक (ग्लोट)",
            "type_label": "अत्यधिक आवक",
            "badge_color": "#EA580C",
            "badge_bg": "#FFEDD5",
            "recommendation_default": "मंडी में अधिक आवक दर्ज की गई है। बेहतर दाम पाने के लिए पास की अन्य मंडियों का चयन करें।",
        },
        "SELLING_OPPORTUNITY": {
            "subject": "💰 मंडी अलर्ट: {commodity} बेचने का अनुशंसित अवसर",
            "type_label": "बिक्री का अनुशंसित अवसर",
            "badge_color": "#0284C7",
            "badge_bg": "#E0F2FE",
            "recommendation_default": "वर्तमान भाव अनुकूल हैं। उपज को बाजार में लाने का यह अच्छा अवसर है।",
        },
        "BETTER_MARKET": {
            "subject": "🏪 मंडी अलर्ट: {commodity} के लिए बेहतर मंडी उपलब्ध",
            "type_label": "बेहतर मंडी उपलब्ध",
            "badge_color": "#7C3AED",
            "badge_bg": "#F3E8FF",
            "recommendation_default": "पड़ोसी मंडी में अधिक भाव दर्ज किया गया है। बेचने से पहले मंडियों की तुलना करें।",
        },
        "AI_RECOMMENDATION": {
            "subject": "🤖 मंडी अलर्ट: {commodity} बाजार परामर्श",
            "type_label": "बाजार परामर्श",
            "badge_color": "#059669",
            "badge_bg": "#D1FAE5",
            "recommendation_default": "7 दिवसीय मूल्य पूर्वानुमान के आधार पर अपनी फसल भेजने की योजना बनाएं।",
        },
        "greeting": "नमस्ते",
        "update_intro": "आपके लिए एक महत्वपूर्ण मंडी अपडेट है।",
        "current_price_label": "वर्तमान मूल्य",
        "previous_price_label": "पिछला मूल्य",
        "change_label": "मूल्य परिवर्तन",
        "recommendation_label": "सलाह / अनुशंसा",
        "footer_cta": "पूर्ण बाजार अंतर्दृष्टि और मूल्य पूर्वानुमान देखने के लिए मंडी इंटेलिजेंस ऐप खोलें।",
        "regards": "सादर,",
        "team_name": "मंडी इंटेलिजेंस टीम",
        "unit": "/ क्विंटल",
    },
    "ml": {
        "PRICE_INCREASE": {
            "subject": "🌾 മണ്ഡി അലേർട്ട്: {commodity} വില വർദ്ധിച്ചു",
            "type_label": "വില വർദ്ധിച്ചു",
            "badge_color": "#16A34A",
            "badge_bg": "#DCFCE7",
            "recommendation_default": "വില ഉയർന്ന തലത്തിൽ ഉള്ളതിനാൽ വിളവ് വിൽക്കുന്ന കാര്യം പരിഗണിക്കുക.",
        },
        "PRICE_DROP": {
            "subject": "📉 മണ്ഡി അലേർട്ട്: {commodity} വില കുറഞ്ഞു",
            "type_label": "വില കുറഞ്ഞു",
            "badge_color": "#DC2626",
            "badge_bg": "#FEE2E2",
            "recommendation_default": "വിപണി വില മെച്ചപ്പെടുന്നതുവരെ ഉൽപ്പന്നങ്ങൾ സൂക്ഷിക്കുന്നത് പരിഗണിക്കുക.",
        },
        "MARKET_GLUT": {
            "subject": "⚠️ മണ്ഡി അലേർട്ട്: {commodity} വൻ വിപണി വരവ്",
            "type_label": "വിപണിയിൽ വൻ വരവ്",
            "badge_color": "#EA580C",
            "badge_bg": "#FFEDD5",
            "recommendation_default": "വിപണിയിൽ ഉൽപ്പന്നങ്ങളുടെ വരവ് കൂടുതലാണ്. മികച്ച വില ലഭിക്കുന്നതിന് സമീപത്തുള്ള മറ്റ് മാർക്കറ്റുകൾ പരിശോധിച്ച് ഉറപ്പുവരുത്തുക.",
        },
        "SELLING_OPPORTUNITY": {
            "subject": "💰 മണ്ഡി അലേർട്ട്: {commodity} മികച്ച വിൽപ്പന അവസരം",
            "type_label": "വിൽപ്പനയ്ക്കുള്ള അനുകൂല അവസരം",
            "badge_color": "#0284C7",
            "badge_bg": "#E0F2FE",
            "recommendation_default": "നിലവിലെ വിലകൾ അനുകൂലമാണ്. ഉൽപ്പന്നങ്ങൾ വിപണിയിലെത്തിക്കാൻ അനുകൂല സമയം.",
        },
        "BETTER_MARKET": {
            "subject": "🏪 മണ്ഡി അലേർട്ട്: {commodity} മെച്ചപ്പെട്ട വിപണി ലഭ്യമാണ്",
            "type_label": "മെച്ചപ്പെട്ട വിപണി ലഭ്യമാണ്",
            "badge_color": "#7C3AED",
            "badge_bg": "#F3E8FF",
            "recommendation_default": "സമീപത്തെ മറ്റൊരു വിപണിയിൽ ഉയർന്ന വില രേഖപ്പെടുത്തിയിട്ടുണ്ട്. വിൽക്കുന്നതിന് മുൻപ് മാർക്കറ്റുകൾ താരതമ്യം ചെയ്യുക.",
        },
        "AI_RECOMMENDATION": {
            "subject": "🤖 മണ്ഡി അലേർട്ട്: {commodity} മാർക്കറ്റ് ഉപദേശം",
            "type_label": "മാർക്കറ്റ് ഉപദേശം",
            "badge_color": "#059669",
            "badge_bg": "#D1FAE5",
            "recommendation_default": "7 ദിവസത്തെ വില പ്രവചനം അടിസ്ഥാനമാക്കി നിങ്ങളുടെ വിളവെടുപ്പും വിപണനവും ആസൂത്രണം ചെയ്യുക.",
        },
        "greeting": "നമസ്കാരം",
        "update_intro": "നിങ്ങൾക്ക് ഒരു പ്രധാന മണ്ഡി അപ്‌ഡേറ്റ് ഉണ്ട്.",
        "current_price_label": "നിലവിലെ വില",
        "previous_price_label": "മുമ്പത്തെ വില",
        "change_label": "വില വ്യതിയാനം",
        "recommendation_label": "നിർദ്ദേശം / ഉപദേശം",
        "footer_cta": "കൂടുതൽ വിവരങ്ങൾക്കും വില പ്രവചനങ്ങൾക്കുമായി മണ്ഡി ഇന്റലിജൻസ് ആപ്പ് തുറക്കുക.",
        "regards": "സ്നേഹാദരങ്ങളോടെ,",
        "team_name": "മണ്ഡി ഇന്റലിജൻസ് ടീം",
        "unit": "/ ക്വിന്റൽ",
    },
}


def _normalize_alert_type_key(alert_type: str) -> str:
    key = str(alert_type).upper()
    mapping = {
        "PRICE_RISE": "PRICE_INCREASE",
        "PRICE_INCREASE": "PRICE_INCREASE",
        "PRICE_FALL": "PRICE_DROP",
        "PRICE_DROP": "PRICE_DROP",
        "MARKET_GLUT": "MARKET_GLUT",
        "SELLING_OPPORTUNITY": "SELLING_OPPORTUNITY",
        "BEST_MANDI": "BETTER_MARKET",
        "BETTER_MARKET": "BETTER_MARKET",
        "GENERAL_ADVISORY": "AI_RECOMMENDATION",
        "AI_RECOMMENDATION": "AI_RECOMMENDATION",
    }
    return mapping.get(key, "PRICE_INCREASE")


class EmailService:
    @staticmethod
    def send_otp_email(email: str, otp: str):
        resend.Emails.send({
            "from": "noreply@mandiintelligence.tech",
            "to": email,
            "subject": "Your Mandi Intelligence OTP",
            "html": f"""
            <p>Hello,</p>

            <p>Your verification code is:</p>

            <h1>{otp}</h1>

            <p>This OTP is valid for 5 minutes.</p>

            <p>If you didn't request this code, you can safely ignore this email.</p>

            <p>Regards,</p>
            <p>Mandi Intelligence</p>
            """
        })

    @classmethod
    def send_alert_email(
        cls,
        email: str,
        user_name: str,
        lang: str,
        alert_type: str,
        commodity_name: str,
        market_name: str,
        title: str,
        message: str,
        current_price: float | None = None,
        previous_price: float | None = None,
        change_percent: float | None = None,
    ) -> bool:
        """
        Delivers a localized, responsive HTML alert email to the user via Resend.
        Returns True if successful, False if invalid email or delivery failure.
        Exceptions are caught gracefully to prevent failing alert generation.
        """
        if not email or "@" not in email:
            logger.info(f"Skipping alert email delivery: Invalid or missing email address '{email}'.")
            return False

        lang_code = lang.lower() if lang and lang.lower() in ALERT_TEMPLATES else "en"
        t = ALERT_TEMPLATES[lang_code]

        type_key = _normalize_alert_type_key(alert_type)
        type_info = t.get(type_key, t["PRICE_INCREASE"])

        subject = type_info["subject"].format(commodity=commodity_name)
        type_label = type_info["type_label"]
        badge_color = type_info["badge_color"]
        badge_bg = type_info["badge_bg"]
        recommendation = message if message and message.strip() else type_info["recommendation_default"]

        formatted_current = f"₹{current_price:,.2f} {t['unit']}" if current_price is not None else "-"
        formatted_prev = f"₹{previous_price:,.2f} {t['unit']}" if previous_price is not None else None
        formatted_change = f"{change_percent:+.1f}%" if change_percent is not None else None

        change_box_html = ""
        if formatted_change:
            change_box_html = f"""
            <td width="50%" style="padding: 12px; background-color: #F9FAFB; border-radius: 8px; border: 1px solid #F3F4F6;">
              <span style="font-size: 12px; color: #6B7280; text-transform: uppercase; font-weight: 600;">{t['change_label']}</span>
              <div style="font-size: 18px; font-weight: 700; color: {badge_color}; margin-top: 4px;">
                {formatted_change}
              </div>
            </td>
            """

        html_content = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{subject}</title>
</head>
<body style="margin: 0; padding: 0; background-color: #F8F9FA; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #1F2937;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #F8F9FA; padding: 20px 10px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" style="max-width: 600px; background-color: #FFFFFF; border-radius: 16px; overflow: hidden; border: 1px solid #E5E7EB; box-shadow: 0 4px 12px rgba(0,0,0,0.05);" cellspacing="0" cellpadding="0">
          
          <!-- Header Banner -->
          <tr>
            <td style="background: linear-gradient(135deg, #1A9809 0%, #158007 100%); padding: 24px 28px; text-align: left;">
              <h1 style="margin: 0; color: #FFFFFF; font-size: 22px; font-weight: 700; letter-spacing: -0.5px;">🌾 Mandi Intelligence</h1>
              <p style="margin: 4px 0 0 0; color: #E2F2E0; font-size: 13px; font-weight: 500;">Smart Mandi Insights & Price Advisory</p>
            </td>
          </tr>

          <!-- Main Content Area -->
          <tr>
            <td style="padding: 28px;">
              
              <!-- Greeting -->
              <p style="margin: 0 0 12px 0; font-size: 16px; color: #374151; font-weight: 600;">
                {t['greeting']} {user_name},
              </p>
              <p style="margin: 0 0 20px 0; font-size: 14px; color: #6B7280; line-height: 1.5;">
                {t['update_intro']}
              </p>

              <!-- Commodity & Market Card -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #FAFBF9; border-radius: 12px; border: 1px solid #EAF3E8; margin-bottom: 20px;">
                <tr>
                  <td style="padding: 20px;">
                    <span style="display: inline-block; background-color: {badge_bg}; color: {badge_color}; font-size: 12px; font-weight: 700; padding: 4px 12px; border-radius: 20px; text-transform: uppercase; letter-spacing: 0.5px;">
                      {type_label}
                    </span>
                    
                    <h2 style="margin: 12px 0 4px 0; font-size: 24px; color: #111827; font-weight: 700;">
                      {commodity_name}
                    </h2>
                    <p style="margin: 0; font-size: 14px; color: #4B5563; font-weight: 500;">
                      📍 {market_name}
                    </p>
                  </td>
                </tr>
              </table>

              <!-- Price Breakdown -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-bottom: 24px;">
                <tr>
                  <td width="50%" style="padding: 12px; background-color: #F9FAFB; border-radius: 8px; border: 1px solid #F3F4F6;">
                    <span style="font-size: 12px; color: #6B7280; text-transform: uppercase; font-weight: 600;">{t['current_price_label']}</span>
                    <div style="font-size: 18px; font-weight: 700; color: #111827; margin-top: 4px;">
                      {formatted_current}
                    </div>
                  </td>
                  {change_box_html}
                </tr>
              </table>

              <!-- Recommendation Card -->
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #F0FDF4; border-left: 4px solid #16A34A; border-radius: 0 8px 8px 0; margin-bottom: 24px;">
                <tr>
                  <td style="padding: 16px;">
                    <h4 style="margin: 0 0 6px 0; font-size: 14px; color: #166534; font-weight: 700; text-transform: uppercase;">
                      💡 {t['recommendation_label']}
                    </h4>
                    <p style="margin: 0; font-size: 14px; color: #15803D; line-height: 1.6; font-weight: 500;">
                      {recommendation}
                    </p>
                  </td>
                </tr>
              </table>

              <!-- App CTA Note -->
              <p style="margin: 0 0 24px 0; font-size: 13px; color: #6B7280; line-height: 1.5; text-align: center;">
                {t['footer_cta']}
              </p>

              <hr style="border: none; border-top: 1px solid #F3F4F6; margin: 24px 0;" />

              <!-- Sign off -->
              <p style="margin: 0; font-size: 13px; color: #9CA3AF;">
                {t['regards']}<br />
                <strong style="color: #4B5563;">{t['team_name']}</strong>
              </p>

            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
"""

        try:
            resend.Emails.send({
                "from": "noreply@mandiintelligence.tech",
                "to": email,
                "subject": subject,
                "html": html_content,
            })
            logger.info(f"Alert email sent successfully to {email} (subject: '{subject}').")
            return True
        except Exception as e:
            logger.error(f"Failed to send alert email to {email}: {e}")
            return False

    