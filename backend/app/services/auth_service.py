import hashlib
import random
import secrets
import string
import uuid
from datetime import datetime, timedelta

from jose import jwt, JWTError
from passlib.context import CryptContext
from app.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
ALGORITHM = "HS256"


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def generate_referral_code() -> str:
    """8-character alphanumeric referral code."""
    return "".join(random.choices(string.ascii_uppercase + string.digits, k=8))


def create_access_token(user_id: str, role: str) -> str:
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return jwt.encode(
        {"sub": user_id, "role": role, "exp": expire, "type": "access"},
        settings.SECRET_KEY,
        algorithm=ALGORITHM,
    )


def create_refresh_token(user_id: str) -> str:
    expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    return jwt.encode(
        {
            "sub": user_id,
            "exp": expire,
            "type": "refresh",
            "jti": str(uuid.uuid4()),
        },
        settings.SECRET_KEY,
        algorithm=ALGORITHM,
    )


def token_jti(token: str) -> str | None:
    """Return a refresh-token JTI without accepting an unverified payload."""
    payload = decode_token(token)
    jti = payload.get("jti")
    return jti if isinstance(jti, str) else None


def hash_token_identifier(identifier: str) -> str:
    """Hash a token identifier before persisting it server-side."""
    return hashlib.sha256(identifier.encode("utf-8")).hexdigest()


def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
    except (JWTError, TypeError, ValueError):
        return {}


def new_oauth_state() -> str:
    """Generate an opaque one-time OAuth state value."""
    return secrets.token_urlsafe(32)
