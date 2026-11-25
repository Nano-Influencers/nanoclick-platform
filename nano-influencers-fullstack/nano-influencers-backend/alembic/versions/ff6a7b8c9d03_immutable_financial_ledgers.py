"""Prevent mutation of financial ledger history and validate platform snapshots.

Revision ID: ff6a7b8c9d03
Revises: fe5f6a7b8c92
"""

from alembic import op

revision = "ff6a7b8c9d03"
down_revision = "fe5f6a7b8c92"
branch_labels = None
depends_on = None


_IMMUTABLE_FUNCTION = """
CREATE OR REPLACE FUNCTION prevent_financial_ledger_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Financial ledger rows are immutable: % on % is not permitted',
        TG_OP, TG_TABLE_NAME
        USING ERRCODE = 'restrict_violation';
END;
$$;
"""

_PLATFORM_INSERT_FUNCTION = """
CREATE OR REPLACE FUNCTION validate_platform_ledger_snapshot()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    current_balance BIGINT;
BEGIN
    SELECT balance_kobo INTO current_balance
    FROM platform_wallets
    WHERE id = NEW.platform_wallet_id;

    IF current_balance IS NULL THEN
        RAISE EXCEPTION 'Platform wallet % does not exist', NEW.platform_wallet_id
            USING ERRCODE = 'foreign_key_violation';
    END IF;

    IF NEW.balance_after_kobo <> current_balance THEN
        RAISE EXCEPTION
            'Platform ledger snapshot % does not match wallet balance %',
            NEW.balance_after_kobo, current_balance
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;
"""


def upgrade():
    op.execute(_IMMUTABLE_FUNCTION)
    op.execute(_PLATFORM_INSERT_FUNCTION)

    op.execute(
        """
        CREATE TRIGGER trg_transactions_immutable
        BEFORE UPDATE OR DELETE ON transactions
        FOR EACH ROW
        EXECUTE FUNCTION prevent_financial_ledger_mutation()
        """
    )
    op.execute(
        """
        CREATE TRIGGER trg_platform_wallet_transactions_immutable
        BEFORE UPDATE OR DELETE ON platform_wallet_transactions
        FOR EACH ROW
        EXECUTE FUNCTION prevent_financial_ledger_mutation()
        """
    )
    op.execute(
        """
        CREATE TRIGGER trg_platform_ledger_snapshot
        BEFORE INSERT ON platform_wallet_transactions
        FOR EACH ROW
        EXECUTE FUNCTION validate_platform_ledger_snapshot()
        """
    )


def downgrade():
    op.execute(
        "DROP TRIGGER IF EXISTS trg_platform_ledger_snapshot ON platform_wallet_transactions"
    )
    op.execute(
        "DROP TRIGGER IF EXISTS trg_platform_wallet_transactions_immutable ON platform_wallet_transactions"
    )
    op.execute("DROP TRIGGER IF EXISTS trg_transactions_immutable ON transactions")
    op.execute("DROP FUNCTION IF EXISTS validate_platform_ledger_snapshot()")
    op.execute("DROP FUNCTION IF EXISTS prevent_financial_ledger_mutation()")
