import pytest
import httpx
from httpx import ASGITransport
from fastapi import HTTPException, Request

from app.config import settings
from app.main import app
from app.services import rate_limit


@pytest.mark.asyncio
async def test_admin_mfa_header_is_allowed_by_cors_preflight():
    async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.options("/admin/mfa/setup", headers={
            "Origin": "http://localhost",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "x-admin-mfa-code,content-type",
        })
    assert response.status_code == 200
    assert "x-admin-mfa-code" in response.headers.get("access-control-allow-headers", "").lower()


@pytest.mark.asyncio
async def test_rate_limiter_fails_closed_when_redis_is_unavailable_in_production(monkeypatch):
    scope = {
        "type": "http", "method": "POST", "path": "/auth/login",
        "headers": [], "query_string": b"", "scheme": "https",
        "server": ("api.example.com", 443), "client": ("127.0.0.1", 12345),
    }
    request = Request(scope)
    monkeypatch.setattr(settings, "APP_ENV", "production")

    def unavailable():
        raise RuntimeError("Redis unavailable")

    monkeypatch.setattr(rate_limit, "_get_redis", unavailable)
    with pytest.raises(HTTPException) as exc:
        await rate_limit.check_rate_limit(request, "login", 5, 60)
    assert exc.value.status_code == 503


@pytest.mark.asyncio
async def test_security_headers_are_returned_on_api_responses():
    async with httpx.AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/health")
    assert response.status_code == 200
    assert response.headers["x-content-type-options"] == "nosniff"
    assert response.headers["x-frame-options"] == "DENY"
    assert response.headers["referrer-policy"] == "strict-origin-when-cross-origin"
