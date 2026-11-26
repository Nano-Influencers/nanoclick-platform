"""Persist notification preferences on each account.

Revision ID: x4y5z6a7b8c
Revises: w3x4y5z6a7b
"""

from alembic import op
import sqlalchemy as sa

revision = "x4y5z6a7b8c"
down_revision = "w3x4y5z6a7b"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column(
        "users",
        sa.Column(
            "notification_preferences",
            sa.JSON(),
            nullable=False,
            server_default=sa.text("'{}'"),
        ),
    )


def downgrade():
    op.drop_column("users", "notification_preferences")
