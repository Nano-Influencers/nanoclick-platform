import hashlib
from collections.abc import Callable

from fastapi import HTTPException, Request
from redis.asyncio import Redis

from app.config import settings


_redis: Redis | None = None


def _client_key(request: Request) -> str:
    # Prefer the socket address. X-Forwarded-For is intentionally ignored here
    # because accepting arbitrary forwarded headers would let clients rotate
    # their own rate-limit identity unless the reverse proxy is trusted.
    host = request.client.host if request.client else "unknown"
    return hashlib.sha256(host.encode("utf-8")).hexdigest()[:32]


def _get_redis() -> Redis:
    global _redis
    if _redis is None:
        _redis = Redis.from_url(settings.REDIS_URL, decode_responses=True)
    return _redis


async def check_rate_limit(request: Request, name: str, limit: int, window_seconds: int) -> None:
    """Apply a fixed-window Redis limiter and raise HTTP 429 when exceeded."""
    if limit < 1 or window_seconds < 1:
        raise ValueError("limit and window_seconds must be positive")

    key = f"nanoclick:rl:{name}:{_client_key(request)}"
    redis = _get_redis()
    try:
        count = await redis.incr(key)
        if count == 1:
            await redis.expire(key, window_seconds)
    except Exception:
        # A Redis outage should not make authentication/payment APIs fail open
        # into an outage. Alert on Redis failures and restore the limiter ASAP.
        return

    if count > limit:
        ttl = await redis.ttl(key)
        raise HTTPException(
            status_code=429,
            detail="Too many requests. Please try again later.",
            headers={"Retry-After": str(max(ttl, 1))},
        )


def rate_limit(name: str, limit: int, window_seconds: int) -> Callable:
    """Return a FastAPI dependency implementing the same limiter."""
    async def dependency(request: Request) -> None:
        await check_rate_limit(request, name, limit, window_seconds)

    return dependency
