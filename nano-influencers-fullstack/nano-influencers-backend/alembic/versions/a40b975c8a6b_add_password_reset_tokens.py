"""add password reset tokens

Revision ID: a40b975c8a6b
Revises: ef457339320b
Create Date: 2026-08-31 11:47:00.859667

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'a40b975c8a6b'
down_revision: Union[str, None] = 'ef457339320b'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # This migration is on a historical branch that can be reached after
    # f7b8c9d0e1f2 on a fresh database. Keep creation idempotent so either
    # branch ordering produces the same schema.
    bind = op.get_bind()
    bind.execute(
        sa.text(
            """
            CREATE TABLE IF NOT EXISTS password_reset_tokens (
                id UUID NOT NULL PRIMARY KEY,
                user_id UUID NOT NULL REFERENCES users(id),
                token VARCHAR(128) NOT NULL,
                expires_at TIMESTAMP NOT NULL,
                used BOOLEAN NOT NULL,
                created_at TIMESTAMP NOT NULL
            )
            """
        )
    )
    bind.execute(
        sa.text(
            "CREATE UNIQUE INDEX IF NOT EXISTS ix_password_reset_tokens_token "
            "ON password_reset_tokens (token)"
        )
    )
    bind.execute(
        sa.text(
            "CREATE INDEX IF NOT EXISTS ix_password_reset_tokens_user_id "
            "ON password_reset_tokens (user_id)"
        )
    )


def downgrade() -> None:
    op.drop_index(op.f('ix_password_reset_tokens_user_id'), table_name='password_reset_tokens')
    op.drop_index(op.f('ix_password_reset_tokens_token'), table_name='password_reset_tokens')
    op.drop_table('password_reset_tokens')
