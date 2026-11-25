"""Add server-authoritative treasure hunt tables.

Revision ID: fg7h8i9j0k1l
Revises: ff6a7b8c9d03
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "fg7h8i9j0k1l"
down_revision = "ff6a7b8c9d03"
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
        "treasure_campaigns",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("name", sa.String(160), nullable=False),
        sa.Column("details", sa.Text(), nullable=False),
        sa.Column("image_url", sa.Text(), nullable=True),
        sa.Column("starts_at", sa.DateTime(), nullable=False),
        sa.Column("ends_at", sa.DateTime(), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="draft"),
        sa.Column("hint_options", postgresql.JSONB(), nullable=False, server_default="[]"),
        sa.Column("claim_code_hash", sa.String(64), nullable=False),
        sa.Column("reward_kobo", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("reward_click_points", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("max_winners", sa.Integer(), nullable=False, server_default="1"),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.CheckConstraint("reward_kobo >= 0", name="ck_treasure_reward_kobo_nonnegative"),
        sa.CheckConstraint("reward_click_points >= 0", name="ck_treasure_reward_points_nonnegative"),
    )
    op.create_index("ix_treasure_campaigns_status", "treasure_campaigns", ["status"])
    op.create_table(
        "treasure_participations",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("campaign_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("treasure_campaigns.id", ondelete="CASCADE"), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("participated", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("found", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("hunted_down", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("claimed", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("hints_used", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("spent_earnings_kobo", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("spent_points", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("items_won", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_hint_at", sa.DateTime(), nullable=True),
        sa.Column("claimed_at", sa.DateTime(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("campaign_id", "user_id", name="uq_treasure_campaign_user"),
        sa.CheckConstraint("hints_used >= 0", name="ck_treasure_hints_nonnegative"),
        sa.CheckConstraint("spent_earnings_kobo >= 0", name="ck_treasure_spent_earnings_nonnegative"),
        sa.CheckConstraint("spent_points >= 0", name="ck_treasure_spent_points_nonnegative"),
    )
    op.create_index("ix_treasure_participations_campaign_id", "treasure_participations", ["campaign_id"])
    op.create_index("ix_treasure_participations_user_id", "treasure_participations", ["user_id"])

def downgrade():
    op.drop_index("ix_treasure_participations_user_id", table_name="treasure_participations")
    op.drop_index("ix_treasure_participations_campaign_id", table_name="treasure_participations")
    op.drop_table("treasure_participations")
    op.drop_index("ix_treasure_campaigns_status", table_name="treasure_campaigns")
    op.drop_table("treasure_campaigns")
