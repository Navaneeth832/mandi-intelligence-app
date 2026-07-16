import requests
from app.core.config import settings

class SMSService:
    @staticmethod
    def send_otp_sms(phone_number: str, otp: str):
        url = "https://www.fast2sms.com/dev/bulkV2"
        
        # Switched to the "q" route and using the "message" payload
        querystring = {
            "authorization": settings.FAST2SMS_API_KEY,
            "message": f"Your Mandi Intelligence OTP is {otp}", # Custom text goes here
            "language": "english",
            "route": "q", # 'q' stands for Quick SMS 
            "numbers": phone_number
        }
        
        headers = {
            'cache-control': "no-cache"
        }
        
        try:
            response = requests.request("GET", url, headers=headers, params=querystring)
            print("SMS API hit! Response:", response.json())
            return True
        except Exception as e:
            print(f"Oof, something broke: {e}")
            return False