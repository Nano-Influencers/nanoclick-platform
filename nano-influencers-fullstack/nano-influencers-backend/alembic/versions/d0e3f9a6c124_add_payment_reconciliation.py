"""add deposit records and Paystack event idempotency

Revision ID: d0e3f9a6c124
Revises: c9d2e8f5b013
Create Date: 2026-09-10
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "d0e3f9a6c124"
down_revision: Union[str, None] = "c9d2e8f5b013"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "deposits",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("reference", sa.String(length=100), nullable=False),
        sa.Column("amount_kobo", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("completed_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("reference"),
    )
    op.create_index("ix_deposits_user_id", "deposits", ["user_id"], unique=False)
    op.create_index("ix_deposits_reference", "deposits", ["reference"], unique=False)

    op.create_table(
        "paystack_events",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("event_id", sa.String(length=150), nullable=False),
        sa.Column("event_type", sa.String(length=80), nullable=False),
        sa.Column("reference", sa.String(length=100), nullable=True),
        sa.Column("processed_at", sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("event_id"),
    )
    op.create_index("ix_paystack_events_event_id", "paystack_events", ["event_id"], unique=False)
    op.create_index("ix_paystack_events_event_type", "paystack_events", ["event_type"], unique=False)
    op.create_index("ix_paystack_events_reference", "paystack_events", ["reference"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_paystack_events_reference", table_name="paystack_events")
    op.drop_index("ix_paystack_events_event_type", table_name="paystack_events")
    op.drop_index("ix_paystack_events_event_id", table_name="paystack_events")
    op.drop_table("paystack_events")
    op.drop_index("ix_deposits_reference", table_name="deposits")
    op.drop_index("ix_deposits_user_id", table_name="deposits")
    op.drop_table("deposits")
