import uuid
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class PasswordResetToken(Base):
    """
    Backs POST /auth/forgot-password + POST /auth/reset-password.

    NOTE: this backend has no email-sending infrastructure configured yet
    (no SMTP/SendGrid/SES settings exist in app.config). The token is
    generated and stored correctly here, but forgot_password() currently
    only *logs* the reset link server-side instead of emailing it — see
    the comment in app/routers/auth.py. Wire up a real mail provider before
    relying on this in production; until then, forgot-password is a
    structurally complete but not end-user-deliverable feature.
    """
    __tablename__ = "password_reset_tokens"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    token: Mapped[str] = mapped_column(String(128), nullable=False, unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    used: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User"] = relationship("User")
