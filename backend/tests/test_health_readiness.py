import pytest
from fastapi import Request

from app.main import app, readiness, request_observability


@pytest.mark.asyncio
async def test_liveness_is_dependency_free():
    route = next(route for route in app.router.routes if getattr(route, "path", None) == "/health/live")
    response = await route.endpoint()
    assert response == {"status": "ok"}


@pytest.mark.asyncio
async def test_readiness_returns_ok_when_database_and_redis_are_healthy(monkeypatch):
    class Connection:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return False

        async def execute(self, _query):
            return None

    class Engine:
        def connect(self):
            return Connection()

    class RedisClient:
        async def ping(self):
            return True

        async def aclose(self):
            return None

    monkeypatch.setattr("app.main.engine", Engine())
    monkeypatch.setattr("app.main.Redis.from_url", lambda *args, **kwargs: RedisClient())

    response = await readiness()
    assert response.status_code == 200
    assert response.body == b'{"status":"ok","checks":{"database":true,"redis":true}}'


@pytest.mark.asyncio
async def test_readiness_returns_503_when_redis_is_unavailable(monkeypatch):
    class Connection:
        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return False

        async def execute(self, _query):
            return None

    class Engine:
        def connect(self):
            return Connection()

    class RedisClient:
        async def ping(self):
            raise ConnectionError("redis unavailable")

        async def aclose(self):
            return None

    monkeypatch.setattr("app.main.engine", Engine())
    monkeypatch.setattr("app.main.Redis.from_url", lambda *args, **kwargs: RedisClient())

    response = await readiness()
    assert response.status_code == 503
    assert response.body == b'{"status":"degraded","checks":{"database":true,"redis":false}}'


@pytest.mark.asyncio
async def test_request_observability_preserves_client_request_id():
    async def call_next(_request: Request):
        from fastapi.responses import Response
        return Response(status_code=204)

    scope = {
        "type": "http",
        "method": "GET",
        "path": "/health/live",
        "headers": [(b"x-request-id", b"test-request-123")],
        "query_string": b"",
        "scheme": "http",
        "server": ("test", 80),
        "client": ("test", 1234),
        "root_path": "",
        "http_version": "1.1",
    }
    request = Request(scope)
    response = await request_observability(request, call_next)
    assert response.headers["X-Request-ID"] == "test-request-123"
