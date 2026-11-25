import uuid
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, ForeignKey, Text, Boolean, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy import String as SAString
from app.database import Base

# TNI service type → CW task category mapping
TNI_TO_CW_CATEGORY: dict[str, str] = {
    "word_of_mouth":    "repeating_single",
    "engaged_growth":   "repeating_grouped",
    "single_one_time":  "one_off_single",
    "custom":           "one_off_grouped",
    "trend_on_x":       "trend_push",
    "high_value":       "skill_based",
    "try_for_free":     "unpaid",
}


class Campaign(Base):
    __tablename__ = "campaigns"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)

    title: Mapped[str] = mapped_column(String(255), nullable=False)
    platform: Mapped[str] = mapped_column(String(50), nullable=False)    # instagram | tiktok | youtube | twitter | facebook | spotify ...
    action_type: Mapped[str] = mapped_column(String(50), nullable=False) # like | follow | comment | share | stream | trend ...
    tni_service_type: Mapped[str] = mapped_column(String(30), nullable=False)
    cw_task_category: Mapped[str] = mapped_column(String(30), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    target_url: Mapped[str | None] = mapped_column(String(500), nullable=True)

    # Pricing — all in kobo
    client_budget_kobo: Mapped[int] = mapped_column(Integer, nullable=False)
    client_price_per_action_kobo: Mapped[int] = mapped_column(Integer, nullable=False)
    worker_pay_per_action_kobo: Mapped[int] = mapped_column(Integer, nullable=False)
    escrow_kobo: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Slot tracking
    slots_total: Mapped[int] = mapped_column(Integer, nullable=False)
    slots_filled: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # status: draft | pending_admin | active | paused | completed | cancelled | reported
    status: Mapped[str] = mapped_column(String(20), default="draft", nullable=False, index=True)

    is_urgent: Mapped[bool] = mapped_column(Boolean, default=False)
    has_targeting: Mapped[bool] = mapped_column(Boolean, default=False)
    has_instructions: Mapped[bool] = mapped_column(Boolean, default=False)
    instructions: Mapped[str | None] = mapped_column(Text, nullable=True)
    comment_subtype: Mapped[str | None] = mapped_column(String(50), nullable=True)
    video_subtype: Mapped[str | None] = mapped_column(String(50), nullable=True)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    owner: Mapped["User"] = relationship("User", back_populates="campaigns")
    tasks: Mapped[list["Task"]] = relationship("Task", back_populates="campaign", cascade="all, delete-orphan")
    targeting: Mapped["CampaignTargeting"] = relationship("CampaignTargeting", back_populates="campaign", uselist=False, cascade="all, delete-orphan")
    allocation_groups: Mapped[list["TaskAllocationGroup"]] = relationship("TaskAllocationGroup", back_populates="campaign", cascade="all, delete-orphan")


class CampaignTargeting(Base):
    __tablename__ = "campaign_targeting"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    campaign_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("campaigns.id"), unique=True, nullable=False)

    target_genders: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_age_brackets: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_marital_statuses: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_income_ranges: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_religions: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_ethnicities: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_races: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_languages: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_cities: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_states: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_countries: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_industries: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_skills: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    target_interests: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list)
    min_follower_count: Mapped[int] = mapped_column(Integer, default=0)
    min_avg_story_views: Mapped[int] = mapped_column(Integer, default=0)

    # Tracks expansion tier (1–9) — updated by Celery cron every 6h
    current_expansion_tier: Mapped[int] = mapped_column(Integer, default=1)
    last_expanded_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    campaign: Mapped["Campaign"] = relationship("Campaign", back_populates="targeting")


class TaskAllocationGroup(Base):
    """Percentage-split sub-actions within a campaign (e.g. 10% like, 70% love, 20% laugh)."""
    __tablename__ = "task_allocation_groups"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    campaign_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("campaigns.id"), nullable=False)
    action_label: Mapped[str] = mapped_column(String(100), nullable=False)
    percentage: Mapped[float] = mapped_column(Float, nullable=False)
    slots_allocated: Mapped[int] = mapped_column(Integer, nullable=False)
    slots_filled: Mapped[int] = mapped_column(Integer, default=0)
    is_complete: Mapped[bool] = mapped_column(Boolean, default=False)

    campaign: Mapped["Campaign"] = relationship("Campaign", back_populates="allocation_groups")
