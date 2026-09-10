import uuid
from datetime import datetime

from sqlalchemy import BigInteger, CheckConstraint, DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class PlatformWalletTransaction(Base):
    """Immutable ledger entry for platform-owned funding and reward-pool spend."""

    __tablename__ = "platform_wallet_transactions"
    __table_args__ = (
        UniqueConstraint(
            "platform_wallet_id",
            "type",
            "reference",
            name="uq_platform_wallet_transaction_reference",
        ),
        CheckConstraint("amount_kobo <> 0", name="ck_platform_wallet_transaction_amount_nonzero"),
        CheckConstraint("balance_after_kobo >= 0", name="ck_platform_wallet_transaction_balance_nonnegative"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    platform_wallet_id: Mapped[int] = mapped_column(
        ForeignKey("platform_wallets.id"), nullable=False, index=True
    )
    type: Mapped[str] = mapped_column(String(40), nullable=False)
    amount_kobo: Mapped[int] = mapped_column(BigInteger, nullable=False)
    balance_after_kobo: Mapped[int] = mapped_column(BigInteger, nullable=False)
    reference: Mapped[str] = mapped_column(String(120), nullable=False, index=True)
    description: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False, index=True)

    platform_wallet: Mapped["PlatformWallet"] = relationship("PlatformWallet")
