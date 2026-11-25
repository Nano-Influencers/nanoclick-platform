from datetime import datetime

from sqlalchemy import BigInteger, CheckConstraint, DateTime, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class PlatformWallet(Base):
    __tablename__ = "platform_wallets"
    __table_args__ = (
        CheckConstraint("balance_kobo >= 0", name="ck_platform_wallet_balance_nonnegative"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    wallet_key: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    balance_kobo: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
