"""Keep total_withdrawn consistent when a withdrawal is reversed.

Revision ID: fd4e5f6a7b81
Revises: fc3d4e5f6a70
"""

from alembic import op

revision = "fd4e5f6a7b81"
down_revision = "fc3d4e5f6a70"
branch_labels = None
depends_on = None

_TRIGGER_FUNCTION = """
CREATE OR REPLACE FUNCTION apply_withdrawal_reversal_to_wallet_totals()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.type = 'withdrawal_reversal' THEN
        UPDATE wallets
        SET total_withdrawn_kobo = GREATEST(0, total_withdrawn_kobo - NEW.amount_kobo),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.wallet_id;
    END IF;
    RETURN NEW;
END;
$$;
"""

_TRIGGER = """
CREATE TRIGGER trg_withdrawal_reversal_wallet_totals
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION apply_withdrawal_reversal_to_wallet_totals();
"""


def upgrade():
    op.execute(_TRIGGER_FUNCTION)
    op.execute(_TRIGGER)


def downgrade():
    op.execute("DROP TRIGGER IF EXISTS trg_withdrawal_reversal_wallet_totals ON transactions")
    op.execute("DROP FUNCTION IF EXISTS apply_withdrawal_reversal_to_wallet_totals()")
