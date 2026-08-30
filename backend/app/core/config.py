from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    SECRET_KEY: str

    SMTP_HOST: str
    SMTP_PORT: int

    SMTP_EMAIL: str
    SMTP_PASSWORD: str

    SMTP_FROM_NAME: str = "Mandi Intelligence"

    RESEND_API_KEY: str
    
    FAST2SMS_API_KEY: str

    API_KEY: str

    FIREBASE_CREDENTIALS_PATH: str | None = None
    FIREBASE_CREDENTIALS_JSON: str | None = None

    
    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore",
    )
   


settings = Settings()
