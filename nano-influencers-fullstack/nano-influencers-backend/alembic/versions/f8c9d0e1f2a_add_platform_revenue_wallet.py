"""Add the platform revenue wallet used to record campaign margin.

Revision ID: f8c9d0e1f2a3
Revises: f7b8c9d0e1f2, 3b8c9d0e1f2a
"""
from alembic import op
import sqlalchemy as sa

revision = "f8c9d0e1f2a3"
down_revision = ("f7b8c9d0e1f2", "3b8c9d0e1f2a")
branch_labels = None
depends_on = None


def upgrade():
    op.execute(
        sa.text(
            "INSERT INTO platform_wallets (wallet_key, balance_kobo) "
            "VALUES ('platform_revenue', 0) "
            "ON CONFLICT (wallet_key) DO NOTHING"
        )
    )


def downgrade():
    op.execute(
        sa.text("DELETE FROM platform_wallets WHERE wallet_key = 'platform_revenue'")
    )
