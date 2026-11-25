"""Merge the reward-wallet and transaction-idempotency migration branches.

Revision ID: f6a7b8c9d0e1
Revises: 3b8c9d0e1f2a, f5e6f7a8b9c0
"""
from alembic import op

revision = "f6a7b8c9d0e1"
down_revision = ("3b8c9d0e1f2a", "f5e6f7a8b9c0")
branch_labels = None
depends_on = None


def upgrade():
    pass


def downgrade():
    pass
