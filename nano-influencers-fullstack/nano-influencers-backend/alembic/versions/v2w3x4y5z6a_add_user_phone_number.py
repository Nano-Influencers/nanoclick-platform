"""Add optional phone number to user profiles.

Revision ID: v2w3x4y5z6a
Revises: u1v2w3x4y5z6
"""
from alembic import op
import sqlalchemy as sa

revision = "v2w3x4y5z6a"
down_revision = "u1v2w3x4y5z6"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("users", sa.Column("phone_number", sa.String(length=32), nullable=True))


def downgrade():
    op.drop_column("users", "phone_number")
