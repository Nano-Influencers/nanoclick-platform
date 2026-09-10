"""Hash legacy password reset tokens before enforcing hashed lookup.

Revision ID: f7b8c9d0e1f2
Revises: f6a7b8c9d0e1
"""
import hashlib

from alembic import op
import sqlalchemy as sa

revision = "f7b8c9d0e1f2"
down_revision = "f6a7b8c9d0e1"
branch_labels = None
depends_on = None


def upgrade():
    bind = op.get_bind()

    # This migration predates the password-reset-token migration on one
    # historical branch. Make the graph safe for fresh databases as well as
    # databases where the table was already created by a40b975c8a6b.
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

    table = sa.table(
        "password_reset_tokens",
        sa.column("id", sa.UUID()),
        sa.column("token", sa.String(length=128)),
    )
    rows = bind.execute(
        sa.select(table.c.id, table.c.token).where(sa.func.length(table.c.token) != 64)
    ).fetchall()
    for row in rows:
        bind.execute(
            table.update()
            .where(table.c.id == row.id)
            .values(token=hashlib.sha256(row.token.encode("utf-8")).hexdigest())
        )


def downgrade():
    # Raw reset tokens cannot be reconstructed from hashes. Keep the hashed
    # values in place rather than weakening the database by attempting a
    # lossy reverse migration.
    pass
