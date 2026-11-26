"""Harden normalized email uniqueness, MFA secret storage, and reset attempts.

Revision ID: y5z6a7b8c9d0
Revises: x4y5z6a7b8c
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

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
    op.create_table(
        "campaign_drafts",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("owner_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("payload", postgresql.JSONB(), nullable=False, server_default=sa.text("'{}'::jsonb")),
        sa.Column("creative_key", sa.String(500), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False),
        sa.Column("updated_at", sa.DateTime(), nullable=False),
    )
    op.create_index("ix_campaign_drafts_owner_id", "campaign_drafts", ["owner_id"])


def downgrade():
    op.drop_index("ix_campaign_drafts_owner_id", table_name="campaign_drafts")
    op.drop_table("campaign_drafts")
    op.drop_column("password_reset_tokens", "attempts")
    op.alter_column("users", "mfa_secret", existing_type=sa.String(length=255), type_=sa.String(length=64), existing_nullable=True)
    op.drop_index("uq_users_email_lower", table_name="users")
