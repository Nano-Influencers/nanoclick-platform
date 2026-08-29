from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    DATABASE_URL: str
    REDIS_URL: str = "redis://localhost:6379/0"
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    PAYSTACK_SECRET_KEY: str = ""
    PAYSTACK_PUBLIC_KEY: str = ""

    S3_ENDPOINT_URL: str = ""
    S3_ACCESS_KEY_ID: str = ""
    S3_SECRET_ACCESS_KEY: str = ""
    S3_BUCKET_NAME: str = "nanoclick-proofs"

    APP_ENV: str = "development"
    FRONTEND_ORIGINS: str = "http://localhost"

    # Midnight bonus window (WAT = UTC+1)
    MIDNIGHT_START_HOUR: int = 0
    MIDNIGHT_END_HOUR: int = 5

    AUTO_APPROVE_HOURS: int = 72
    DEFAULT_TASK_ACCEPT_MINUTES: int = 30
    TARGETING_EXPANSION_HOURS: int = 6

    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""

    FACEBOOK_CLIENT_ID: str = ""
    FACEBOOK_CLIENT_SECRET: str = ""

    OAUTH_REDIRECT_BASE: str = "http://localhost:8000"

    @property
    def allowed_origins(self) -> list[str]:
        return [o.strip() for o in self.FRONTEND_ORIGINS.split(",")]


settings = Settings()
