import hashlib
from collections.abc import Awaitable, Callable

from fastapi import HTTPException, Request
from redis.asyncio import Redis

from app.config import settings


_redis: Redis | None = None


def _client_key(request: Request) -> str:
    # Prefer the socket address. X-Forwarded-For is intentionally ignored here
    # because accepting arbitrary forwarded headers would let clients rotate
    # their own rate-limit identity unless the reverse proxy is trusted and
    # configured explicitly.
    host = request.client.host if request.client else "unknown"
    return hashlib.sha256(host.encode("utf-8")).hexdigest()[:32]


def _get_redis() -> Redis:
    global _redis
    if _redis is None:
        _redis = Redis.from_url(settings.REDIS_URL, decode_responses=True)
    return _redis


def rate_limit(name: str, limit: int, window_seconds: int) -> Callable:
    """Return a FastAPI dependency implementing a fixed-window Redis limiter."""
    if limit < 1 or window_seconds < 1:
        raise ValueError("limit and window_seconds must be positive")

    async def dependency(request: Request) -> None:
        key = f"nanoclick:rl:{name}:{_client_key(request)}"
        redis = _get_redis()
        try:
            count = await redis.incr(key)
            if count == 1:
                await redis.expire(key, window_seconds)
        except Exception:
            # Availability of Redis must not turn authentication/payment APIs
            # into a hard outage. Production monitoring should alert on Redis
            # failures; the application remains usable until Redis recovers.
            return

        if count > limit:
            ttl = await redis.ttl(key)
            headers = {"Retry-After": str(max(ttl, 1))}
            raise HTTPException(
                status_code=429,
                detail="Too many requests. Please try again later.",
                headers=headers,
            )

    return dependency
