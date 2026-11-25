import httpx
from app.config import settings

GOOGLE_TOKEN_URL    = "https://oauth2.googleapis.com/token"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo"
FACEBOOK_TOKEN_URL  = "https://graph.facebook.com/v19.0/oauth/access_token"
FACEBOOK_USERINFO_URL = "https://graph.facebook.com/me"


def google_auth_url(state: str) -> str:
    from urllib.parse import urlencode
    return "https://accounts.google.com/o/oauth2/v2/auth?" + urlencode({
        "client_id": settings.GOOGLE_CLIENT_ID,
        "redirect_uri": f"{settings.OAUTH_REDIRECT_BASE}/auth/google/callback",
        "response_type": "code",
        "scope": "openid email profile",
        "state": state,
        "access_type": "offline",
    })


async def exchange_google_code(code: str) -> dict:
    async with httpx.AsyncClient(timeout=15) as client:
        token_resp = await client.post(GOOGLE_TOKEN_URL, data={
            "code": code,
            "client_id": settings.GOOGLE_CLIENT_ID,
            "client_secret": settings.GOOGLE_CLIENT_SECRET,
            "redirect_uri": f"{settings.OAUTH_REDIRECT_BASE}/auth/google/callback",
            "grant_type": "authorization_code",
        })
        token_resp.raise_for_status()
        user_resp = await client.get(
            GOOGLE_USERINFO_URL,
            headers={"Authorization": f"Bearer {token_resp.json()['access_token']}"},
        )
        user_resp.raise_for_status()
        d = user_resp.json()
    return {
        "provider": "google",
        "provider_id": d["id"],
        "email": d.get("email", ""),
        "full_name": d.get("name", ""),
        "email_verified": d.get("verified_email", False),
    }


def facebook_auth_url(state: str) -> str:
    from urllib.parse import urlencode
    return "https://www.facebook.com/v19.0/dialog/oauth?" + urlencode({
        "client_id": settings.FACEBOOK_CLIENT_ID,
        "redirect_uri": f"{settings.OAUTH_REDIRECT_BASE}/auth/facebook/callback",
        "state": state,
        "scope": "email,public_profile",
    })


async def exchange_facebook_code(code: str) -> dict:
    async with httpx.AsyncClient(timeout=15) as client:
        token_resp = await client.get(FACEBOOK_TOKEN_URL, params={
            "client_id": settings.FACEBOOK_CLIENT_ID,
            "client_secret": settings.FACEBOOK_CLIENT_SECRET,
            "redirect_uri": f"{settings.OAUTH_REDIRECT_BASE}/auth/facebook/callback",
            "code": code,
        })
        token_resp.raise_for_status()
        user_resp = await client.get(
            FACEBOOK_USERINFO_URL,
            params={"fields": "id,name,email", "access_token": token_resp.json()["access_token"]},
        )
        user_resp.raise_for_status()
        d = user_resp.json()
    return {
        "provider": "facebook",
        "provider_id": d["id"],
        "email": d.get("email", ""),
        "full_name": d.get("name", ""),
        "email_verified": True,
    }
