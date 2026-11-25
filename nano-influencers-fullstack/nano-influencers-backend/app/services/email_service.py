"""Small SMTP adapter for transactional account email."""
import asyncio
import smtplib
from email.message import EmailMessage

from app.config import settings


def _send_reset_email_sync(recipient: str, reset_url: str) -> None:
    message = EmailMessage()
    message["Subject"] = "Reset your NanoClick password"
    message["From"] = settings.SMTP_FROM_EMAIL
    message["To"] = recipient
    message.set_content(
        "We received a request to reset your NanoClick password.\n\n"
        f"Reset your password here: {reset_url}\n\n"
        "This link expires in 1 hour and can only be used once. "
        "If you did not request this, you can ignore this email."
    )
    with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=15) as smtp:
        if settings.SMTP_USE_TLS:
            smtp.starttls()
        if settings.SMTP_USERNAME:
            smtp.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)
        smtp.send_message(message)


async def send_password_reset_email(recipient: str, token: str) -> None:
    """Send a reset link without blocking the async request loop."""
    reset_url = f"{settings.PASSWORD_RESET_URL.rstrip('/')}?token={token}"
    await asyncio.to_thread(_send_reset_email_sync, recipient, reset_url)
