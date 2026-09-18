import uuid
from datetime import datetime
from sqlalchemy import Boolean, CheckConstraint, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database import Base

class TreasureCampaign(Base):
    __tablename__ = "treasure_campaigns"
    __table_args__ = (
        CheckConstraint("reward_kobo >= 0", name="ck_treasure_reward_kobo_nonnegative"),
        CheckConstraint("reward_click_points >= 0", name="ck_treasure_reward_points_nonnegative"),
    )
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(String(160), nullable=False)
    details: Mapped[str] = mapped_column(Text, nullable=False)
    image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    starts_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    ends_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="draft", nullable=False, index=True)
    hint_options: Mapped[list[str]] = mapped_column(JSONB, default=list, nullable=False)
    claim_code_hash: Mapped[str] = mapped_column(String(64), nullable=False)
    reward_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    reward_click_points: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    max_winners: Mapped[int] = mapped_column(Integer, default=1, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    participations: Mapped[list["TreasureParticipation"]] = relationship(back_populates="campaign")

class TreasureParticipation(Base):
    __tablename__ = "treasure_participations"
    __table_args__ = (
        UniqueConstraint("campaign_id", "user_id", name="uq_treasure_campaign_user"),
        CheckConstraint("hints_used >= 0", name="ck_treasure_hints_nonnegative"),
        CheckConstraint("spent_earnings_kobo >= 0", name="ck_treasure_spent_earnings_nonnegative"),
        CheckConstraint("spent_points >= 0", name="ck_treasure_spent_points_nonnegative"),
    )
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    campaign_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("treasure_campaigns.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    participated: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    found: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    hunted_down: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    claimed: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    hints_used: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    spent_earnings_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    spent_points: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    items_won: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    last_hint_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    claimed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
    campaign: Mapped["TreasureCampaign"] = relationship(back_populates="participations")
