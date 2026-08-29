import uuid
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, ForeignKey, Boolean, Text, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy import String as SAString
from app.database import Base


class Task(Base):
    __tablename__ = "tasks"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    campaign_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("campaigns.id"), nullable=False, index=True)
    allocation_group_id: Mapped[uuid.UUID | None] = mapped_column(UUID(as_uuid=True), ForeignKey("task_allocation_groups.id"), nullable=True)

    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    link: Mapped[str | None] = mapped_column(String(500), nullable=True)
    instructions: Mapped[str | None] = mapped_column(Text, nullable=True)
    platform: Mapped[str] = mapped_column(String(50), nullable=False)
    action_type: Mapped[str] = mapped_column(String(50), nullable=False)
    cw_task_category: Mapped[str] = mapped_column(String(30), nullable=False)

    # difficulty: simple | difficult
    difficulty: Mapped[str] = mapped_column(String(20), default="simple", nullable=False)
    is_high_earning: Mapped[bool] = mapped_column(Boolean, default=False)   # worker pay >= ₦500
    is_urgent: Mapped[bool] = mapped_column(Boolean, default=False)
    is_midnight: Mapped[bool] = mapped_column(Boolean, default=False)       # set by cron at midnight window

    pay_kobo: Mapped[int] = mapped_column(Integer, nullable=False)
    click_points_base: Mapped[int] = mapped_column(Integer, default=0)      # pre-calculated base CPs

    slots_total: Mapped[int] = mapped_column(Integer, nullable=False)
    slots_filled: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # status: available | completed | cancelled | reported_removed
    status: Mapped[str] = mapped_column(String(20), default="available", nullable=False, index=True)

    # Per-worker acceptance timer in minutes
    accept_timeout_minutes: Mapped[int] = mapped_column(Integer, default=30, nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    campaign: Mapped["Campaign"] = relationship("Campaign", back_populates="tasks")
    submissions: Mapped[list["Submission"]] = relationship("Submission", back_populates="task")
    acceptances: Mapped[list["TaskAcceptance"]] = relationship("TaskAcceptance", back_populates="task")
    reports: Mapped[list["TaskReport"]] = relationship("TaskReport", back_populates="task")


class TaskAcceptance(Base):
    """One row per worker-per-task acceptance. Stores the per-worker countdown timer."""
    __tablename__ = "task_acceptances"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False, index=True)
    worker_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    accepted_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    # status: active | expired | submitted | cancelled
    status: Mapped[str] = mapped_column(String(20), default="active", nullable=False)

    task: Mapped["Task"] = relationship("Task", back_populates="acceptances")
    worker: Mapped["User"] = relationship("User", back_populates="task_acceptances")


class Submission(Base):
    __tablename__ = "submissions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False, index=True)
    worker_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    acceptance_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("task_acceptances.id"), nullable=False)

    # status: pending | under_review | queried | approved | rejected
    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False, index=True)

    proof_urls: Mapped[list[str]] = mapped_column(ARRAY(SAString), default=list, nullable=False)
    proof_link: Mapped[str | None] = mapped_column(String(500), nullable=True)
    proof_image_hash: Mapped[str | None] = mapped_column(String(64), nullable=True)  # pHash for duplicate detection

    rejection_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    query_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    admin_feedback: Mapped[str | None] = mapped_column(Text, nullable=True)
    client_rating: Mapped[float | None] = mapped_column(Float, nullable=True)       # 1–5 stars; feeds leaderboard CR

    task_speed_minutes: Mapped[float | None] = mapped_column(Float, nullable=True)  # accept → submit time
    was_auto_approved: Mapped[bool] = mapped_column(Boolean, default=False)

    submitted_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    task: Mapped["Task"] = relationship("Task", back_populates="submissions")
    worker: Mapped["User"] = relationship("User", back_populates="submissions")


class TaskReport(Base):
    __tablename__ = "task_reports"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    task_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("tasks.id"), nullable=False)
    reporter_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    reason: Mapped[str] = mapped_column(Text, nullable=False)
    # status: pending | upheld | dismissed
    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)
    cp_reward_given: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    task: Mapped["Task"] = relationship("Task", back_populates="reports")


class LeaderboardScore(Base):
    __tablename__ = "leaderboard_scores"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    worker_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    period: Mapped[str] = mapped_column(String(10), nullable=False)           # weekly | monthly
    period_start: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    period_end: Mapped[datetime] = mapped_column(DateTime, nullable=False)

    avg_speed_minutes: Mapped[float] = mapped_column(Float, default=0)
    avg_client_rating: Mapped[float] = mapped_column(Float, default=0)
    tasks_approved: Mapped[int] = mapped_column(Integer, default=0)
    tasks_rejected: Mapped[int] = mapped_column(Integer, default=0)
    tasks_completed: Mapped[int] = mapped_column(Integer, default=0)

    cat_one_off_single: Mapped[int] = mapped_column(Integer, default=0)
    cat_one_off_grouped: Mapped[int] = mapped_column(Integer, default=0)
    cat_repeating_single: Mapped[int] = mapped_column(Integer, default=0)
    cat_repeating_grouped: Mapped[int] = mapped_column(Integer, default=0)
    cat_trend_push: Mapped[int] = mapped_column(Integer, default=0)
    cat_skill_based: Mapped[int] = mapped_column(Integer, default=0)
    cat_unpaid: Mapped[int] = mapped_column(Integer, default=0)

    ts_score: Mapped[float] = mapped_column(Float, default=0)
    cr_score: Mapped[float] = mapped_column(Float, default=0)
    ar_score: Mapped[float] = mapped_column(Float, default=0)
    tq_score: Mapped[float] = mapped_column(Float, default=0)
    td_score: Mapped[float] = mapped_column(Float, default=0)
    total_score: Mapped[float] = mapped_column(Float, default=0)
    rank: Mapped[int | None] = mapped_column(Integer, nullable=True)
    computed_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
