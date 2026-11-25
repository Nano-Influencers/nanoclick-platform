"""add one-time web OAuth authorization codes

Revision ID: c9d2e8f5b013
Revises: b8c1d7e4a921
Create Date: 2026-09-10
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "c9d2e8f5b013"
down_revision: Union[str, None] = "b8c1d7e4a921"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "oauth_codes",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("code_hash", sa.String(length=64), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("redirect_uri", sa.String(length=500), nullable=True),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("used_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("code_hash"),
    )
    op.create_index("ix_oauth_codes_code_hash", "oauth_codes", ["code_hash"], unique=False)
    op.create_index("ix_oauth_codes_user_id", "oauth_codes", ["user_id"], unique=False)
    op.create_index("ix_oauth_codes_expires_at", "oauth_codes", ["expires_at"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_oauth_codes_expires_at", table_name="oauth_codes")
    op.drop_index("ix_oauth_codes_user_id", table_name="oauth_codes")
    op.drop_index("ix_oauth_codes_code_hash", table_name="oauth_codes")
    op.drop_table("oauth_codes")
