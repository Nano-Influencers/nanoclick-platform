"""enforce unique transaction references per wallet and type

Revision ID: f5e6f7a8b9c0
Revises: f4d5e6f7a8b9
"""
from alembic import op

revision = "f5e6f7a8b9c0"
down_revision = "f4d5e6f7a8b9"
branch_labels = None
depends_on = None


def upgrade():
    # Do not silently delete financial ledger history. If legacy duplicate
    # references exist, force reconciliation before production migration.
    op.execute("""
        DO $$
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM transactions
                WHERE reference IS NOT NULL
                GROUP BY wallet_id, type, reference
                HAVING COUNT(*) > 1
            ) THEN
                RAISE EXCEPTION
                    'Cannot add transaction idempotency constraint: duplicate non-null references exist';
            END IF;
        END $$;
    """)

    op.create_unique_constraint(
        "uq_transaction_wallet_type_reference",
        "transactions",
        ["wallet_id", "type", "reference"],
    )


def downgrade():
    op.drop_constraint(
        "uq_transaction_wallet_type_reference",
        "transactions",
        type_="unique",
    )
