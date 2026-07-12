import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
#import time

from app.core.config import settings
import resend
from app.core.config import settings

resend.api_key = settings.RESEND_API_KEY



class EmailService:
    @staticmethod
    def send_otp_email(email: str, otp: str):
        #start=time.time()
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
        #print(f"Send API took {time.time()-start:.2f} seconds")
    