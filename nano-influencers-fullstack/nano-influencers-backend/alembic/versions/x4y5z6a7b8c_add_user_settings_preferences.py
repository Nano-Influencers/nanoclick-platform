"""Persist user notification and regional preferences.

Revision ID: x4y5z6a7b8c
Revises: w3x4y5z6a7b
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "x4y5z6a7b8c"
down_revision = "w3x4y5z6a7b"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "users",
        sa.Column(
            "notification_preferences",
            postgresql.JSONB(),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
    )
    op.add_column(
        "users",
        sa.Column(
            "regional_preferences",
            postgresql.JSONB(),
            nullable=False,
            server_default=sa.text("'{}'::jsonb"),
        ),
    )


def downgrade():
    op.drop_column("users", "regional_preferences")
    op.drop_column("users", "notification_preferences")
