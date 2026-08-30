import uuid
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class Wallet(Base):
    __tablename__ = "wallets"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), unique=True, nullable=False)

    # All monetary values in kobo (1 NGN = 100 kobo — avoids float precision errors)
    balance_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    escrow_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)   # locked campaign budgets

    click_points: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_earned_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_withdrawn_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    total_spent_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Per-category daily earnings (reset at midnight WAT by Celery cron)
    daily_one_off_single_kobo: Mapped[int] = mapped_column(Integer, default=0)
    daily_one_off_grouped_kobo: Mapped[int] = mapped_column(Integer, default=0)
    daily_repeating_single_kobo: Mapped[int] = mapped_column(Integer, default=0)
    daily_repeating_grouped_kobo: Mapped[int] = mapped_column(Integer, default=0)
    daily_trend_push_kobo: Mapped[int] = mapped_column(Integer, default=0)
    daily_skill_based_kobo: Mapped[int] = mapped_column(Integer, default=0)
    daily_unpaid_kobo: Mapped[int] = mapped_column(Integer, default=0)
    daily_reset_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    # Spin-to-win / daily check-in gamification (once-per-24h actions)
    last_spin_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    last_checkin_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    checkin_streak: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Per-category lifetime earnings
    total_one_off_single_kobo: Mapped[int] = mapped_column(Integer, default=0)
    total_one_off_grouped_kobo: Mapped[int] = mapped_column(Integer, default=0)
    total_repeating_single_kobo: Mapped[int] = mapped_column(Integer, default=0)
    total_repeating_grouped_kobo: Mapped[int] = mapped_column(Integer, default=0)
    total_trend_push_kobo: Mapped[int] = mapped_column(Integer, default=0)
    total_skill_based_kobo: Mapped[int] = mapped_column(Integer, default=0)
    total_unpaid_kobo: Mapped[int] = mapped_column(Integer, default=0)

    # Per-category daily click points
    daily_one_off_single_cps: Mapped[int] = mapped_column(Integer, default=0)
    daily_one_off_grouped_cps: Mapped[int] = mapped_column(Integer, default=0)
    daily_repeating_single_cps: Mapped[int] = mapped_column(Integer, default=0)
    daily_repeating_grouped_cps: Mapped[int] = mapped_column(Integer, default=0)
    daily_trend_push_cps: Mapped[int] = mapped_column(Integer, default=0)
    daily_skill_based_cps: Mapped[int] = mapped_column(Integer, default=0)
    daily_unpaid_cps: Mapped[int] = mapped_column(Integer, default=0)

    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    user: Mapped["User"] = relationship("User", back_populates="wallet")
    transactions: Mapped[list["Transaction"]] = relationship("Transaction", back_populates="wallet", order_by="Transaction.created_at.desc()")


class Transaction(Base):
    __tablename__ = "transactions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    wallet_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("wallets.id"), nullable=False, index=True)

    # type: deposit | withdrawal | withdrawal_reversal | escrow_lock | escrow_release
    #        task_earning | referral_bonus | report_reward | spin_win | checkin_reward
    #        reward_tier_bonus
    type: Mapped[str] = mapped_column(String(30), nullable=False)
    task_category: Mapped[str | None] = mapped_column(String(40), nullable=True)
    amount_kobo: Mapped[int] = mapped_column(Integer, nullable=False)
    click_points_awarded: Mapped[int] = mapped_column(Integer, default=0)
    # status: pending | completed | failed
    status: Mapped[str] = mapped_column(String(20), default="completed", nullable=False)
    reference: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    description: Mapped[str | None] = mapped_column(String(255), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)

    wallet: Mapped["Wallet"] = relationship("Wallet", back_populates="transactions")
