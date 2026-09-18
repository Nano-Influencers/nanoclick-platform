"""Record click point spending in wallet transactions.

Revision ID: hi9j0k1l2m3n
Revises: gh8i9j0k1l2m
"""
from alembic import op
import sqlalchemy as sa

revision = "hi9j0k1l2m3n"
down_revision = "gh8i9j0k1l2m"
branch_labels = None
depends_on = None

def upgrade():
    op.add_column("transactions", sa.Column("click_points_spent", sa.Integer(), nullable=False, server_default="0"))
    op.create_check_constraint("ck_transaction_click_points_spent_nonnegative", "transactions", "click_points_spent >= 0")

def downgrade():
    op.drop_constraint("ck_transaction_click_points_spent_nonnegative", "transactions", type_="check")
    op.drop_column("transactions", "click_points_spent")
