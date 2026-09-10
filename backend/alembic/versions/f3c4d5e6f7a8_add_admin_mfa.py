"""add admin MFA fields

Revision ID: f3c4d5e6f7a8
Revises: f2b3c4d5e6f7
"""
from alembic import op
import sqlalchemy as sa

revision = "f3c4d5e6f7a8"
down_revision = "f2b3c4d5e6f7"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("users", sa.Column("mfa_secret", sa.String(length=64), nullable=True))
    op.add_column("users", sa.Column("mfa_enabled", sa.Boolean(), nullable=False, server_default=sa.false()))
    op.alter_column("users", "mfa_enabled", server_default=None)


def downgrade():
    op.drop_column("users", "mfa_enabled")
    op.drop_column("users", "mfa_secret")
