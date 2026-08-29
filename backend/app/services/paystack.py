import hashlib
import hmac
import httpx
from app.config import settings

PAYSTACK_BASE = "https://api.paystack.co"


async def initialize_transaction(email: str, amount_kobo: int, reference: str) -> dict:
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            f"{PAYSTACK_BASE}/transaction/initialize",
            json={"email": email, "amount": amount_kobo, "reference": reference},
            headers={"Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["data"]


async def verify_transaction(reference: str) -> dict:
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.get(
            f"{PAYSTACK_BASE}/transaction/verify/{reference}",
            headers={"Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["data"]


async def initiate_transfer(
    amount_kobo: int,
    recipient_code: str,
    reference: str,
    reason: str = "ClickWorker withdrawal",
) -> dict:
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            f"{PAYSTACK_BASE}/transfer",
            json={"source": "balance", "amount": amount_kobo,
                  "recipient": recipient_code, "reference": reference, "reason": reason},
            headers={"Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["data"]


def verify_webhook_signature(payload: bytes, signature: str) -> bool:
    """HMAC-SHA512 — key must be bytes (Bug 1 fix: encode before passing)."""
    expected = hmac.new(
        settings.PAYSTACK_SECRET_KEY.encode("utf-8"),
        payload,
        hashlib.sha512,
    ).hexdigest()
    return hmac.compare_digest(expected, signature)
