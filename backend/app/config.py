from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    DATABASE_URL: str
    REDIS_URL: str = "redis://localhost:6379/0"
    SECRET_KEY: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # Browser refresh sessions are kept in an HttpOnly cookie. The cookie is
    # scoped to /auth so application JavaScript cannot read it and unrelated
    # routes do not receive it. Native clients continue using bearer refresh
    # tokens in their platform-secure storage.
    AUTH_COOKIE_SECURE: bool = False
    AUTH_COOKIE_SAMESITE: str = "lax"

    PAYSTACK_SECRET_KEY: str = ""
    PAYSTACK_PUBLIC_KEY: str = ""
    PAYSTACK_CALLBACK_URL: str = "http://localhost:5173/payment-return.html"

    S3_ENDPOINT_URL: str = ""
    S3_ACCESS_KEY_ID: str = ""
    S3_SECRET_ACCESS_KEY: str = ""
    S3_BUCKET_NAME: str = "nanoclick-proofs"

    APP_ENV: str = "development"
    FRONTEND_ORIGINS: str = "http://localhost"

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
    OAUTH_WEB_REDIRECT_URL: str = "http://localhost:5173/oauth-callback"
    OAUTH_ALLOWED_WEB_REDIRECTS: str = "http://localhost:5173/oauth-callback,http://localhost:8080/"

    REFERRAL_BONUS_KOBO: int = 20000
    CHECKIN_BASE_REWARD_KOBO: int = 5000
    CHECKIN_STREAK_STEP_KOBO: int = 2500
    CHECKIN_STREAK_CAP_DAYS: int = 7
    SPIN_COOLDOWN_HOURS: int = 24

    @model_validator(mode="after")
    def validate_production_security(self):
        """Fail closed on deployment settings that are unsafe in production."""
        env = self.APP_ENV.strip().lower()
        if self.AUTH_COOKIE_SAMESITE.lower() not in {"lax", "strict", "none"}:
            raise ValueError("AUTH_COOKIE_SAMESITE must be lax, strict, or none")
        if self.AUTH_COOKIE_SAMESITE.lower() == "none" and not self.AUTH_COOKIE_SECURE:
            raise ValueError("AUTH_COOKIE_SECURE must be true when AUTH_COOKIE_SAMESITE is none")

        if env not in {"production", "prod"}:
            return self

        if len(self.SECRET_KEY) < 32:
            raise ValueError("SECRET_KEY must be at least 32 characters in production")

        origins = self.allowed_origins
        if not origins or any(origin == "*" or not origin for origin in origins):
            raise ValueError("FRONTEND_ORIGINS must be explicit non-wildcard origins in production")
        if any("localhost" in origin.lower() or "127.0.0.1" in origin for origin in origins):
            raise ValueError("FRONTEND_ORIGINS must not contain localhost/127.0.0.1 in production")
        if any(not origin.startswith("https://") for origin in origins):
            raise ValueError("FRONTEND_ORIGINS must use HTTPS in production")

        if not self.PAYSTACK_SECRET_KEY or not self.PAYSTACK_PUBLIC_KEY:
            raise ValueError("Paystack keys must be configured in production")
        if not self.S3_ENDPOINT_URL or not self.S3_ACCESS_KEY_ID or not self.S3_SECRET_ACCESS_KEY:
            raise ValueError("Private object-storage credentials must be configured in production")
        if not self.AUTH_COOKIE_SECURE:
            raise ValueError("AUTH_COOKIE_SECURE must be true in production")

        for name, value in (
            ("OAUTH_REDIRECT_BASE", self.OAUTH_REDIRECT_BASE),
            ("OAUTH_WEB_REDIRECT_URL", self.OAUTH_WEB_REDIRECT_URL),
            ("PAYSTACK_CALLBACK_URL", self.PAYSTACK_CALLBACK_URL),
        ):
            if not value.startswith("https://"):
                raise ValueError(f"{name} must use HTTPS in production")
            if "localhost" in value.lower() or "127.0.0.1" in value:
                raise ValueError(f"{name} must not point to localhost/127.0.0.1 in production")

        redirects = [url.strip() for url in self.OAUTH_ALLOWED_WEB_REDIRECTS.split(",") if url.strip()]
        if not redirects:
            raise ValueError("OAUTH_ALLOWED_WEB_REDIRECTS must contain at least one redirect in production")
        if any(not url.startswith("https://") for url in redirects):
            raise ValueError("OAUTH_ALLOWED_WEB_REDIRECTS must use HTTPS in production")
        if any("localhost" in url.lower() or "127.0.0.1" in url for url in redirects):
            raise ValueError("OAUTH_ALLOWED_WEB_REDIRECTS must not contain localhost/127.0.0.1 in production")

        return self

    @property
    def allowed_origins(self) -> list[str]:
        return [o.strip() for o in self.FRONTEND_ORIGINS.split(",") if o.strip()]


settings = Settings()
