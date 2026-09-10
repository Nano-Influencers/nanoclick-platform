"""Add platform reward funding wallet.

Revision ID: 2a7b8c9d0e1f
Revises: 1c6f2d99a696
"""
from alembic import op
import sqlalchemy as sa

revision = "2a7b8c9d0e1f"
down_revision = "1c6f2d99a696"
branch_labels = None

def upgrade():
    op.create_table(
        "platform_wallets",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("wallet_key", sa.String(length=64), nullable=False),
        sa.Column("balance_kobo", sa.BigInteger(), nullable=False, server_default="0"),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("wallet_key", name="uq_platform_wallet_key"),
        sa.CheckConstraint("balance_kobo >= 0", name="ck_platform_wallet_balance_nonnegative"),
    )
    op.execute(
        "INSERT INTO platform_wallets (wallet_key, balance_kobo) VALUES ('reward_pool', 0)"
    )

def downgrade():
    op.drop_table("platform_wallets")
