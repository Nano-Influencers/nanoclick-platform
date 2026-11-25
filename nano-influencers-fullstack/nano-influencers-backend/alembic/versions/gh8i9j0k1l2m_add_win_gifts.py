"""Add server-authoritative win gifts.

Revision ID: gh8i9j0k1l2m
Revises: fg7h8i9j0k1l
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "gh8i9j0k1l2m"
down_revision = "fg7h8i9j0k1l"
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
        "gift_campaigns",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("title", sa.String(160), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("image_url", sa.Text(), nullable=True),
        sa.Column("prize_name", sa.String(160), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="draft"),
        sa.Column("starts_at", sa.DateTime(), nullable=False),
        sa.Column("ends_at", sa.DateTime(), nullable=False),
        sa.Column("entry_cost_points", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("max_winners", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint("entry_cost_points >= 0", name="ck_gift_entry_cost_nonnegative"),
        sa.CheckConstraint("max_winners >= 1", name="ck_gift_max_winners_positive"),
    )
    op.create_index("ix_gift_campaigns_status", "gift_campaigns", ["status"])
    op.create_table(
        "gift_entries",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("campaign_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gift_campaigns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("entered_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("status", sa.String(20), nullable=False, server_default="entered"),
        sa.UniqueConstraint("campaign_id", "user_id", name="uq_gift_campaign_user"),
    )
    op.create_index("ix_gift_entries_campaign_id", "gift_entries", ["campaign_id"])
    op.create_index("ix_gift_entries_user_id", "gift_entries", ["user_id"])
    op.create_table(
        "gift_winners",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("campaign_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("gift_campaigns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("selected_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("status", sa.String(20), nullable=False, server_default="selected"),
        sa.Column("fulfilled_at", sa.DateTime(), nullable=True),
        sa.UniqueConstraint("campaign_id", "user_id", name="uq_gift_campaign_winner"),
    )
    op.create_index("ix_gift_winners_campaign_id", "gift_winners", ["campaign_id"])
    op.create_index("ix_gift_winners_user_id", "gift_winners", ["user_id"])

def downgrade():
    op.drop_index("ix_gift_winners_user_id", table_name="gift_winners")
    op.drop_index("ix_gift_winners_campaign_id", table_name="gift_winners")
    op.drop_table("gift_winners")
    op.drop_index("ix_gift_entries_user_id", table_name="gift_entries")
    op.drop_index("ix_gift_entries_campaign_id", table_name="gift_entries")
    op.drop_table("gift_entries")
    op.drop_index("ix_gift_campaigns_status", table_name="gift_campaigns")
    op.drop_table("gift_campaigns")
