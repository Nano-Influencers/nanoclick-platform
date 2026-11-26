"""Resend HTTP API adapter for transactional account email.

Render Free services block outbound SMTP ports, so all transactional email
is delivered over HTTPS through Resend's API.
"""
import httpx

from app.config import settings


RESEND_API_URL = "https://api.resend.com/emails"


async def _send_email(recipient: str, subject: str, text: str) -> None:
    """Deliver a transactional email through Resend over HTTPS."""
    # Keep SMTP_PASSWORD as a temporary fallback for existing deployments.
    api_key = settings.RESEND_API_KEY or settings.SMTP_PASSWORD
    if not api_key:
        raise RuntimeError("RESEND_API_KEY is not configured")
    if not settings.SMTP_FROM_EMAIL:
        raise RuntimeError("SMTP_FROM_EMAIL is not configured")

    payload = {
        "from": settings.SMTP_FROM_EMAIL,
        "to": [recipient],
        "subject": subject,
        "text": text,
    }
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=httpx.Timeout(20.0, connect=10.0)) as client:
        response = await client.post(RESEND_API_URL, json=payload, headers=headers)
        if response.is_error:
            raise RuntimeError(
                f"Resend email API returned HTTP {response.status_code}: "
                f"{response.text[:500]}"
            )


async def send_password_reset_email(recipient: str, token: str) -> None:
    """Send a short-lived password-reset verification code."""
    text = (
        "Your NanoClick password reset token is:\n\n"
        f"{token}\n\n"
        "This token expires in 15 minutes and can only be used once. "
        "If you did not request this, you can ignore this email."
    )
    await _send_email(recipient, "Your NanoClick password reset token", text)


async def send_verification_otp(recipient: str, code: str) -> None:
    """Send an email verification code using Resend's HTTPS API."""
    text = (
        "Your Nano Influencers verification code is:\n\n"
        f"{code}\n\n"
        "This code expires in 10 minutes. If you did not request it, ignore this email."
    )
    await _send_email(recipient, "Your Nano Influencers verification code", text)


async def send_support_message(recipient: str, sender_name: str, sender_email: str, message: str) -> None:
    """Forward an authenticated customer's support request to the configured inbox."""
    text = (
        f"Support request from {sender_name} <{sender_email}>\n\n"
        f"{message}\n"
    )
    await _send_email(recipient, "Nano Influencers support request", text)
