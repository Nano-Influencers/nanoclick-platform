"""add one-time OAuth exchange codes

Revision ID: 8e3a7b1c2d4f
Revises: 7d2e6f9a1b3c
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "8e3a7b1c2d4f"
down_revision: Union[str, None] = "7d2e6f9a1b3c"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "oauth_codes",
        sa.Column("id", sa.UUID(), nullable=False),
        sa.Column("code_hash", sa.String(length=128), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("used_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("code_hash"),
    )
    op.create_index("ix_oauth_codes_code_hash", "oauth_codes", ["code_hash"], unique=True)
    op.create_index("ix_oauth_codes_expires_at", "oauth_codes", ["expires_at"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_oauth_codes_expires_at", table_name="oauth_codes")
    op.drop_index("ix_oauth_codes_code_hash", table_name="oauth_codes")
    op.drop_table("oauth_codes")
