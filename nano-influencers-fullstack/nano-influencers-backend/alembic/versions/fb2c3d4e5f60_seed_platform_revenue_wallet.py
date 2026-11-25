"""Seed the platform revenue wallet required for campaign settlement.

Revision ID: fb2c3d4e5f60
Revises: fa1b2c3d4e5f
"""

from alembic import op

revision = "fb2c3d4e5f60"
down_revision = "fa1b2c3d4e5f"
branch_labels = None
depends_on = None


def upgrade():
    op.execute(
        "INSERT INTO platform_wallets (wallet_key, balance_kobo) "
        "VALUES ('platform_revenue', 0) "
        "ON CONFLICT (wallet_key) DO NOTHING"
    )


def downgrade():
    op.execute(
        "DELETE FROM platform_wallets WHERE wallet_key = 'platform_revenue'"
    )
