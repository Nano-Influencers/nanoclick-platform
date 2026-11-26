import hashlib
import ipaddress
import logging
from collections.abc import Callable

from fastapi import HTTPException, Request
from redis.asyncio import Redis

from app.config import settings

logger = logging.getLogger("nanoclick.rate_limit")
_redis: Redis | None = None
_FIXED_WINDOW_SCRIPT = """
local count = redis.call('INCR', KEYS[1])
if count == 1 then redis.call('EXPIRE', KEYS[1], ARGV[1]) end
local ttl = redis.call('TTL', KEYS[1])
return {count, ttl}
"""


def _trusted_proxy(host: str) -> bool:
    try:
        address = ipaddress.ip_address(host)
        return any(address in ipaddress.ip_network(item.strip(), strict=False)
                   for item in settings.TRUSTED_PROXY_IPS.split(",") if item.strip())
    except ValueError:
        return False


def _client_key(request: Request) -> str:
    host = request.client.host if request.client else "unknown"
    if _trusted_proxy(host):
        forwarded = request.headers.get("x-forwarded-for", "").split(",")[0].strip()
        if forwarded:
            try:
                host = str(ipaddress.ip_address(forwarded))
            except ValueError:
                pass
    return hashlib.sha256(host.encode("utf-8")).hexdigest()[:32]


def _get_redis() -> Redis:
    global _redis
    if _redis is None:
        _redis = Redis.from_url(settings.REDIS_URL, decode_responses=True)
    return _redis


async def check_rate_limit(request: Request, name: str, limit: int, window_seconds: int) -> None:
    """Apply atomic IP + account fixed-window limits; fail closed in production."""
    if limit < 1 or window_seconds < 1:
        raise ValueError("limit and window_seconds must be positive")
    ip_key = _client_key(request)
    identity = getattr(request.state, "rate_limit_identity", None)
    identity_key = hashlib.sha256(str(identity).strip().lower().encode("utf-8")).hexdigest()[:32] if identity else "anonymous"
    redis = _get_redis()
    try:
        dimensions = [("ip", ip_key)] + ([("account", identity_key)] if identity else [])
        for dimension, digest in dimensions:
            key = f"nanoclick:rl:{name}:{dimension}:{digest}"
            count, ttl = await redis.eval(_FIXED_WINDOW_SCRIPT, 1, key, window_seconds)
            if int(count) > limit:
                raise HTTPException(status_code=429, detail="Too many requests. Please try again later.",
                                    headers={"Retry-After": str(max(int(ttl), 1))})
    except HTTPException:
        raise
    except Exception as exc:
        logger.exception("rate_limit_unavailable name=%s path=%s", name, request.url.path)
        if settings.APP_ENV.strip().lower() in {"production", "prod"}:
            raise HTTPException(status_code=503, detail="Security rate limiting is temporarily unavailable.") from exc


def rate_limit(name: str, limit: int, window_seconds: int) -> Callable:
    async def dependency(request: Request) -> None:
        await check_rate_limit(request, name, limit, window_seconds)
    return dependency
