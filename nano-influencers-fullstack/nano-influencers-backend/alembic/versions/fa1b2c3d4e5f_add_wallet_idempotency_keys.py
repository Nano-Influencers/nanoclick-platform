"""add wallet operation idempotency keys

Revision ID: fa1b2c3d4e5f
Revises: f9a0b1c2d3e4
"""

from alembic import op
import sqlalchemy as sa

revision = "fa1b2c3d4e5f"
down_revision = "f9a0b1c2d3e4"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("deposits", sa.Column("idempotency_key", sa.String(length=100), nullable=True))
    op.add_column("deposits", sa.Column("authorization_url", sa.String(length=1000), nullable=True))
    op.create_index("ix_deposits_idempotency_key", "deposits", ["idempotency_key"])
    op.create_unique_constraint(
        "uq_deposits_user_idempotency",
        "deposits",
        ["user_id", "idempotency_key"],
    )

    op.add_column("withdrawals", sa.Column("idempotency_key", sa.String(length=100), nullable=True))
    op.create_index("ix_withdrawals_idempotency_key", "withdrawals", ["idempotency_key"])
    op.create_unique_constraint(
        "uq_withdrawals_user_idempotency",
        "withdrawals",
        ["user_id", "idempotency_key"],
    )


def downgrade():
    op.drop_constraint("uq_withdrawals_user_idempotency", "withdrawals", type_="unique")
    op.drop_index("ix_withdrawals_idempotency_key", table_name="withdrawals")
    op.drop_column("withdrawals", "idempotency_key")

    op.drop_constraint("uq_deposits_user_idempotency", "deposits", type_="unique")
    op.drop_index("ix_deposits_idempotency_key", table_name="deposits")
    op.drop_column("deposits", "authorization_url")
    op.drop_column("deposits", "idempotency_key")
