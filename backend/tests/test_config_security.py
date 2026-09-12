import pytest
from pydantic import ValidationError

from app.config import Settings


BASE = {
    "DATABASE_URL": "postgresql+asyncpg://user:pass@db:5432/nanoclick",
    "SECRET_KEY": "x" * 40,
    "APP_ENV": "production",
    "FRONTEND_ORIGINS": "https://app.example.com",
    "PAYSTACK_SECRET_KEY": "sk_live_example",
    "PAYSTACK_PUBLIC_KEY": "pk_live_example",
    "PAYSTACK_CALLBACK_URL": "https://app.example.com/payment-return.html",
    "S3_ENDPOINT_URL": "https://storage.example.com",
    "S3_ACCESS_KEY_ID": "access",
    "S3_SECRET_ACCESS_KEY": "secret",
    "OAUTH_REDIRECT_BASE": "https://api.example.com",
    "OAUTH_WEB_REDIRECT_URL": "https://app.example.com/oauth-callback",
    "OAUTH_ALLOWED_WEB_REDIRECTS": "https://app.example.com/oauth-callback",
    "AUTH_COOKIE_SECURE": True,
}


def test_production_settings_accept_explicit_secure_configuration():
    settings = Settings(**BASE)
    assert settings.APP_ENV == "production"
    assert settings.allowed_origins == ["https://app.example.com"]


@pytest.mark.parametrize(
    "overrides",
    [
        {"SECRET_KEY": "short"},
        {"FRONTEND_ORIGINS": "*"},
        {"FRONTEND_ORIGINS": "http://app.example.com"},
        {"FRONTEND_ORIGINS": "https://localhost:5173"},
        {"PAYSTACK_SECRET_KEY": ""},
        {"S3_SECRET_ACCESS_KEY": ""},
        {"OAUTH_REDIRECT_BASE": "http://api.example.com"},
        {"OAUTH_WEB_REDIRECT_URL": "http://app.example.com/oauth-callback"},
        {"PAYSTACK_CALLBACK_URL": "http://app.example.com/payment-return.html"},
        {"OAUTH_ALLOWED_WEB_REDIRECTS": "https://app.example.com/oauth-callback,http://localhost:5173/oauth-callback"},
    ],
)
def test_production_settings_reject_unsafe_values(overrides):
    values = {**BASE, **overrides}
    with pytest.raises(ValidationError):
        Settings(**values)


def test_non_production_settings_keep_local_development_defaults():
    settings = Settings(
        DATABASE_URL=BASE["DATABASE_URL"],
        SECRET_KEY="short",
        APP_ENV="development",
    )
    assert settings.allowed_origins == ["http://localhost"]
