import hashlib
import hmac
import httpx
from app.config import settings

PAYSTACK_BASE = "https://api.paystack.co"


class PaystackTransferNotFound(Exception):
    """The provider confirms that no transfer exists for this reference."""


class PaystackTransferVerificationError(Exception):
    """The transfer state could not be determined safely."""


async def initialize_transaction(email: str, amount_kobo: int, reference: str) -> dict:
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            f"{PAYSTACK_BASE}/transaction/initialize",
            json={
                "email": email,
                "amount": amount_kobo,
                "reference": reference,
                "callback_url": settings.PAYSTACK_CALLBACK_URL,
            },
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


async def resolve_account_number(account_number: str, bank_code: str) -> dict:
    """Look up the account holder's name for a given bank account before a
    withdrawal, so the worker can confirm it's correct — and so we fail fast
    on a bad account number instead of debiting the wallet first."""
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.get(
            f"{PAYSTACK_BASE}/bank/resolve",
            params={"account_number": account_number, "bank_code": bank_code},
            headers={"Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["data"]


async def create_transfer_recipient(account_number: str, bank_code: str, account_name: str) -> str:
    """Paystack transfers require a recipient_code, obtained by registering
    the bank account first — you cannot transfer directly to an account
    number. Returns the recipient_code to pass into initiate_transfer."""
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            f"{PAYSTACK_BASE}/transferrecipient",
            json={"type": "nuban", "name": account_name,
                  "account_number": account_number, "bank_code": bank_code, "currency": "NGN"},
            headers={"Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["data"]["recipient_code"]


async def initiate_transfer(
    amount_kobo: int,
    recipient_code: str,
    reference: str,
    reason: str = "ClickWorker withdrawal",
) -> dict:
    """recipient_code must come from create_transfer_recipient() — Paystack
    transfers go to a registered recipient, never directly to a raw account
    number."""
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            f"{PAYSTACK_BASE}/transfer",
            json={"source": "balance", "amount": amount_kobo,
                  "recipient": recipient_code, "reference": reference, "reason": reason},
            headers={"Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["data"]


async def verify_transfer(reference: str) -> dict:
    """Fetch the provider-side transfer state for a stable transfer reference.

    A 404 is materially different from a timeout/5xx: only the former proves
    that no transfer exists and therefore permits a new initiate call.
    """
    async with httpx.AsyncClient(timeout=30) as client:
        try:
            resp = await client.get(
                f"{PAYSTACK_BASE}/transfer/verify/{reference}",
                headers={"Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"},
            )
            resp.raise_for_status()
        except httpx.HTTPStatusError as exc:
            if exc.response.status_code == 404:
                raise PaystackTransferNotFound(reference) from exc
            raise PaystackTransferVerificationError(
                f"Paystack transfer verification returned HTTP {exc.response.status_code}"
            ) from exc
        except httpx.HTTPError as exc:
            raise PaystackTransferVerificationError(
                "Paystack transfer verification failed before provider state could be determined"
            ) from exc
        try:
            payload = resp.json()
            return payload["data"]
        except (ValueError, KeyError, TypeError) as exc:
            raise PaystackTransferVerificationError(
                "Paystack returned an invalid transfer verification response"
            ) from exc


def verify_webhook_signature(payload: bytes, signature: str) -> bool:
    """HMAC-SHA512 — key must be bytes (Bug 1 fix: encode before passing)."""
    expected = hmac.new(
        settings.PAYSTACK_SECRET_KEY.encode("utf-8"),
        payload,
        hashlib.sha512,
    ).hexdigest()
    return hmac.compare_digest(expected, signature)
