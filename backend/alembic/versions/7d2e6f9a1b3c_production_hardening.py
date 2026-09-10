"""production hardening: oauth states and transaction idempotency

Revision ID: 7d2e6f9a1b3c
Revises: a40b975c8a6b
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "7d2e6f9a1b3c"
down_revision: Union[str, None] = "a40b975c8a6b"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "oauth_states",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("state_hash", sa.String(length=128), nullable=False),
        sa.Column("provider", sa.String(length=20), nullable=False),
        sa.Column("role", sa.String(length=20), nullable=False),
        sa.Column("platform", sa.String(length=20), nullable=False),
        sa.Column("redirect_uri", sa.String(length=500), nullable=True),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("used_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("state_hash"),
    )
    op.create_index("ix_oauth_states_state_hash", "oauth_states", ["state_hash"], unique=True)
    op.create_index("ix_oauth_states_expires_at", "oauth_states", ["expires_at"], unique=False)
    op.create_unique_constraint("uq_transaction_wallet_type_reference", "transactions", ["wallet_id", "type", "reference"])


def downgrade() -> None:
    op.drop_constraint("uq_transaction_wallet_type_reference", "transactions", type_="unique")
    op.drop_index("ix_oauth_states_expires_at", table_name="oauth_states")
    op.drop_index("ix_oauth_states_state_hash", table_name="oauth_states")
    op.drop_table("oauth_states")
