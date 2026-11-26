"""Harden normalized email uniqueness, MFA secret storage, and reset attempts.

Revision ID: y5z6a7b8c9d0
Revises: x4y5z6a7b8c
"""
from alembic import op
import sqlalchemy as sa

revision = "y5z6a7b8c9d0"
down_revision = "x4y5z6a7b8c"
branch_labels = None
depends_on = None


def upgrade():
    op.execute("""
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1 FROM users GROUP BY lower(trim(email)) HAVING count(*) > 1
      ) THEN
        RAISE EXCEPTION 'Cannot normalize emails: duplicate case-insensitive user emails exist';
      END IF;
    END $$;
    """)
    op.execute("UPDATE users SET email = lower(trim(email))")
    op.execute("CREATE UNIQUE INDEX uq_users_email_lower ON users (lower(email))")
    op.alter_column("users", "mfa_secret", existing_type=sa.String(length=64), type_=sa.String(length=255), existing_nullable=True)
    op.add_column("password_reset_tokens", sa.Column("attempts", sa.Integer(), nullable=False, server_default="0"))


def downgrade():
    op.drop_column("password_reset_tokens", "attempts")
    op.alter_column("users", "mfa_secret", existing_type=sa.String(length=255), type_=sa.String(length=64), existing_nullable=True)
    op.drop_index("uq_users_email_lower", table_name="users")
