import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, ForeignKey, Text, Integer, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base


class Notification(Base):
    """
    Persisted notification feed for both apps. Replaces the old Firestore
    listener pattern (click-workers) and the nonexistent notification store
    (nano-influencers) with a single polled/pulled backend feed.

    type examples: task_approved | task_rejected | campaign_approved |
    campaign_rejected | kyc_approved | kyc_rejected | deposit_success |
    withdrawal_processed | referral_bonus | reward_tier_unlocked |
    report_upheld
    """
    __tablename__ = "notifications"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)

    type: Mapped[str] = mapped_column(String(40), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    data: Mapped[dict | None] = mapped_column(JSON, nullable=True)  # arbitrary structured payload (task_id, amount, etc.)

    is_read: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)

    user: Mapped["User"] = relationship("User")


class RewardClaim(Base):
    """
    Records a one-time (or pool-distribution) reward payout so it can never
    be granted twice. reward_key examples: 'grit_level10_pool',
    'gratis_level10_pool'. One row per (user_id, reward_key).
    """
    __tablename__ = "reward_claims"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    reward_key: Mapped[str] = mapped_column(String(60), nullable=False, index=True)
    amount_kobo: Mapped[int] = mapped_column(Integer, default=0)
    claimed_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User"] = relationship("User")
