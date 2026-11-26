"""Add persistent user profile avatar storage keys.

Revision ID: w3x4y5z6a7b
Revises: f9a0b1c2d3e4, v2w3x4y5z6a
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "w3x4y5z6a7b"
down_revision = ("f9a0b1c2d3e4", "v2w3x4y5z6a")
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("users", sa.Column("avatar_key", sa.String(length=500), nullable=True))
    op.add_column("users", sa.Column("notification_preferences", postgresql.JSONB(), nullable=False, server_default=sa.text("'{}'")))
    op.add_column("users", sa.Column("regional_preferences", postgresql.JSONB(), nullable=False, server_default=sa.text("'{}'")))


def downgrade():
    op.drop_column("users", "regional_preferences")
    op.drop_column("users", "notification_preferences")
    op.drop_column("users", "avatar_key")
