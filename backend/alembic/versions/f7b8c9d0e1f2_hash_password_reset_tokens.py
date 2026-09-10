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
