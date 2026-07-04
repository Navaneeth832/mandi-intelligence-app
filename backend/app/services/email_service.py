import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

from app.core.config import settings


class EmailService:

    @staticmethod
    def send_otp_email(email: str, otp: str):

        message = MIMEMultipart()

        message["From"] = f"{settings.SMTP_FROM_NAME} <{settings.SMTP_EMAIL}>"
        message["To"] = email
        message["Subject"] = "Your Mandi Intelligence OTP"

        body = f"""
Hello,

Your verification code is:

{otp}

This OTP is valid for 5 minutes.

If you didn't request this code, you can safely ignore this email.

Regards,
Mandi Intelligence
"""

        message.attach(MIMEText(body, "plain"))

        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
            server.starttls()
            server.login(
                settings.SMTP_EMAIL,
                settings.SMTP_PASSWORD,
            )
            server.send_message(message)