from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    SECRET_KEY: str

    SMTP_HOST: str
    SMTP_PORT: int

    SMTP_EMAIL: str
    SMTP_PASSWORD: str

    SMTP_FROM_NAME: str = "Mandi Intelligence"

    RESEND_API_KEY: str
    
    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore",
    )
   


settings = Settings()