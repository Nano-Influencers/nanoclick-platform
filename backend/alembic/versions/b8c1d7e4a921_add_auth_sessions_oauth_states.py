"""add server-side auth sessions and OAuth states

Revision ID: b8c1d7e4a921
Revises: ef457339320b
Create Date: 2026-09-10
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = "b8c1d7e4a921"
down_revision: Union[str, None] = "ef457339320b"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "auth_sessions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("token_jti_hash", sa.String(length=64), nullable=False),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("last_used_at", sa.DateTime(), nullable=True),
        sa.Column("revoked_at", sa.DateTime(), nullable=True),
        sa.Column("replaced_by_jti_hash", sa.String(length=64), nullable=True),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("token_jti_hash"),
    )
    op.create_index("ix_auth_sessions_user_id", "auth_sessions", ["user_id"], unique=False)
    op.create_index("ix_auth_sessions_token_jti_hash", "auth_sessions", ["token_jti_hash"], unique=False)
    op.create_index("ix_auth_sessions_expires_at", "auth_sessions", ["expires_at"], unique=False)

    op.create_table(
        "oauth_states",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("nonce_hash", sa.String(length=64), nullable=False),
        sa.Column("role", sa.String(length=20), nullable=False),
        sa.Column("platform", sa.String(length=10), nullable=False),
        sa.Column("redirect_uri", sa.String(length=500), nullable=True),
        sa.Column("expires_at", sa.DateTime(), nullable=False),
        sa.Column("consumed_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("nonce_hash"),
    )
    op.create_index("ix_oauth_states_nonce_hash", "oauth_states", ["nonce_hash"], unique=False)
    op.create_index("ix_oauth_states_expires_at", "oauth_states", ["expires_at"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_oauth_states_expires_at", table_name="oauth_states")
    op.drop_index("ix_oauth_states_nonce_hash", table_name="oauth_states")
    op.drop_table("oauth_states")
    op.drop_index("ix_auth_sessions_expires_at", table_name="auth_sessions")
    op.drop_index("ix_auth_sessions_token_jti_hash", table_name="auth_sessions")
    op.drop_index("ix_auth_sessions_user_id", table_name="auth_sessions")
    op.drop_table("auth_sessions")
