import uuid
from datetime import datetime
from sqlalchemy import DateTime, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column
from app.database import Base

class CampaignWorkerAudience(Base):
    __tablename__ = "campaign_worker_audience"
    __table_args__ = (
        UniqueConstraint("campaign_id", "worker_id", name="uq_campaign_worker_audience"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    campaign_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("campaigns.id", ondelete="CASCADE"), nullable=False, index=True)
    worker_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    expansion_tier: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    eligibility_reason: Mapped[str] = mapped_column(String(120), nullable=False, default="targeting")
    first_eligible_at: Mapped[datetime] = mapped_column(DateTime, nullable=False, default=datetime.utcnow)
    notified_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    visible_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
