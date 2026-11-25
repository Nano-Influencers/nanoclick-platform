"""Add immutable platform reward wallet ledger.

Revision ID: 3b8c9d0e1f2a
Revises: 2a7b8c9d0e1f
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "3b8c9d0e1f2a"
down_revision = "2a7b8c9d0e1f"
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        "platform_wallet_transactions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("platform_wallet_id", sa.Integer(), nullable=False),
        sa.Column("type", sa.String(length=40), nullable=False),
        sa.Column("amount_kobo", sa.BigInteger(), nullable=False),
        sa.Column("balance_after_kobo", sa.BigInteger(), nullable=False),
        sa.Column("reference", sa.String(length=120), nullable=False),
        sa.Column("description", sa.String(length=255), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["platform_wallet_id"], ["platform_wallets.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "platform_wallet_id",
            "type",
            "reference",
            name="uq_platform_wallet_transaction_reference",
        ),
        sa.CheckConstraint("amount_kobo <> 0", name="ck_platform_wallet_transaction_amount_nonzero"),
        sa.CheckConstraint("balance_after_kobo >= 0", name="ck_platform_wallet_transaction_balance_nonnegative"),
    )
    op.create_index(
        "ix_platform_wallet_transactions_platform_wallet_id",
        "platform_wallet_transactions",
        ["platform_wallet_id"],
    )
    op.create_index(
        "ix_platform_wallet_transactions_reference",
        "platform_wallet_transactions",
        ["reference"],
    )
    op.create_index(
        "ix_platform_wallet_transactions_created_at",
        "platform_wallet_transactions",
        ["created_at"],
    )


def downgrade():
    op.drop_index("ix_platform_wallet_transactions_created_at", table_name="platform_wallet_transactions")
    op.drop_index("ix_platform_wallet_transactions_reference", table_name="platform_wallet_transactions")
    op.drop_index("ix_platform_wallet_transactions_platform_wallet_id", table_name="platform_wallet_transactions")
    op.drop_table("platform_wallet_transactions")
