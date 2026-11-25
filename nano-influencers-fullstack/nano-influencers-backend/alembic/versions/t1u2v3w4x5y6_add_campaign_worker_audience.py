"""Add auditable campaign worker audience allocations.

Revision ID: t1u2v3w4x5y6
Revises: hi9j0k1l2m3n
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "t1u2v3w4x5y6"
down_revision = "hi9j0k1l2m3n"
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
        "campaign_worker_audience",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("campaign_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("campaigns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("worker_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("expansion_tier", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("eligibility_reason", sa.String(120), nullable=False, server_default="targeting"),
        sa.Column("first_eligible_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("notified_at", sa.DateTime(), nullable=True),
        sa.Column("visible_at", sa.DateTime(), nullable=True),
        sa.UniqueConstraint("campaign_id", "worker_id", name="uq_campaign_worker_audience"),
    )
    op.create_index("ix_campaign_worker_audience_campaign_id", "campaign_worker_audience", ["campaign_id"])
    op.create_index("ix_campaign_worker_audience_worker_id", "campaign_worker_audience", ["worker_id"])

def downgrade():
    op.drop_index("ix_campaign_worker_audience_worker_id", table_name="campaign_worker_audience")
    op.drop_index("ix_campaign_worker_audience_campaign_id", table_name="campaign_worker_audience")
    op.drop_table("campaign_worker_audience")
