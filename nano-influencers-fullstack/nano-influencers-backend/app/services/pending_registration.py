"""Short-lived Redis storage for registrations awaiting email verification.

Only a password hash is stored. No user/email record is written to PostgreSQL
until the OTP is verified successfully.
"""
import hashlib
import json
import secrets

from redis.asyncio import Redis

from app.config import settings

_PENDING_TTL_SECONDS = 600
_redis_client: Redis | None = None
_RELEASE_LOCK_SCRIPT = """
if redis.call('GET', KEYS[1]) == ARGV[1] then
    return redis.call('DEL', KEYS[1])
end
return 0
"""


def _redis() -> Redis:
    global _redis_client
    if _redis_client is None:
        _redis_client = Redis.from_url(settings.REDIS_URL, decode_responses=True)
    return _redis_client


def _email_key(email: str) -> str:
    digest = hashlib.sha256(email.strip().lower().encode("utf-8")).hexdigest()
    return f"nanoclick:pending-registration:{digest}"


def _lock_key(email: str) -> str:
    return f"{_email_key(email)}:verify-lock"


async def save_pending_registration(email: str, payload: dict) -> None:
    await _redis().set(
        _email_key(email),
        json.dumps(payload, separators=(",", ":")),
        ex=_PENDING_TTL_SECONDS,
    )


async def load_pending_registration(email: str) -> dict | None:
    raw = await _redis().get(_email_key(email))
    return json.loads(raw) if raw else None


async def delete_pending_registration(email: str) -> None:
    await _redis().delete(_email_key(email))


async def acquire_pending_lock(email: str, token: str) -> bool:
    return bool(await _redis().set(_lock_key(email), token, ex=30, nx=True))


async def release_pending_lock(email: str, token: str) -> None:
    await _redis().eval(_RELEASE_LOCK_SCRIPT, 1, _lock_key(email), token)
