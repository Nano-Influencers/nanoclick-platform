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
    # Where to send the browser after a *web* OAuth login (click-workers is a
    # Flutter Web build, so the mobile deep link nanoclick://oauth?... doesn't
    # apply to it — see /auth/google/login?platform=web).
    OAUTH_WEB_REDIRECT_URL: str = "http://localhost:5173/oauth-callback"
    # Comma-separated allowlist of origins/URLs a caller may pass as its own
    # ?redirect_uri= for web OAuth — required since nano-influencers and
    # click-workers are two different web origins that both need their own
    # callback page, and an unvalidated redirect_uri would let anyone mint
    # a link that hands a freshly-issued token to an attacker-controlled page.
    OAUTH_ALLOWED_WEB_REDIRECTS: str = "http://localhost:5173/oauth-callback,http://localhost:8080/"

    # Gamification amounts (kobo). Not discoverable from the existing
    # Firestore-based client, since it wrote these values directly without
    # a server-authoritative source of truth — these are a documented,
    # conservative starting point, easy to retune without a code change.
    REFERRAL_BONUS_KOBO: int = 20000          # ₦200, paid to the referrer on the referred worker's first approved submission
    CHECKIN_BASE_REWARD_KOBO: int = 5000       # ₦50 on day 1 of a check-in streak
    CHECKIN_STREAK_STEP_KOBO: int = 2500       # +₦25 per consecutive day, capped at CHECKIN_STREAK_CAP_DAYS
    CHECKIN_STREAK_CAP_DAYS: int = 7           # streak reward plateaus after a 7-day cycle, then repeats
    SPIN_COOLDOWN_HOURS: int = 24

    @property
    def allowed_origins(self) -> list[str]:
        return [o.strip() for o in self.FRONTEND_ORIGINS.split(",")]


settings = Settings()
