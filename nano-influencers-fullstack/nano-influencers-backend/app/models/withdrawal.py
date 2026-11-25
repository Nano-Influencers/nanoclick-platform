import uuid
from datetime import datetime
from sqlalchemy import CheckConstraint, DateTime, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from app.database import Base


class Withdrawal(Base):
    __tablename__ = "withdrawals"
    __table_args__ = (
        UniqueConstraint("user_id", "idempotency_key", name="uq_withdrawals_user_idempotency"),
        CheckConstraint(
            "status IN ('requested', 'processing', 'successful', 'failed', 'reversed')",
            name="ck_withdrawals_status",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    reference: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    amount_kobo: Mapped[int] = mapped_column(Integer, nullable=False)
    account_number: Mapped[str] = mapped_column(String(20), nullable=False)
    bank_code: Mapped[str] = mapped_column(String(20), nullable=False)
    account_name: Mapped[str] = mapped_column(String(150), nullable=False)
    # requested -> processing -> successful | failed | reversed
    status: Mapped[str] = mapped_column(String(30), default="requested", nullable=False, index=True)
    recipient_code: Mapped[str | None] = mapped_column(String(100), nullable=True)
    provider_reference: Mapped[str | None] = mapped_column(String(150), nullable=True)
    failure_reason: Mapped[str | None] = mapped_column(String(255), nullable=True)
    idempotency_key: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
