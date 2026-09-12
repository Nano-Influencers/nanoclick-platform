"""Enforce the withdrawal lifecycle at the database boundary.

Revision ID: fc3d4e5f6a70
Revises: fb2c3d4e5f60
"""

from alembic import op

revision = "fc3d4e5f6a70"
down_revision = "fb2c3d4e5f60"
branch_labels = None
depends_on = None


_TRIGGER_FUNCTION = """
CREATE OR REPLACE FUNCTION enforce_withdrawal_status_transition()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status = OLD.status THEN
        RETURN NEW;
    END IF;

    IF (OLD.status = 'requested' AND NEW.status = 'processing')
       OR (OLD.status = 'processing' AND NEW.status IN ('successful', 'failed', 'reversed')) THEN
        RETURN NEW;
    END IF;

    RAISE EXCEPTION
        'Invalid withdrawal status transition: % -> %',
        OLD.status, NEW.status
        USING ERRCODE = 'check_violation';
END;
$$;
"""


_TRIGGER = """
CREATE TRIGGER trg_withdrawal_status_transition
BEFORE UPDATE OF status ON withdrawals
FOR EACH ROW
EXECUTE FUNCTION enforce_withdrawal_status_transition();
"""


def upgrade():
    op.create_check_constraint(
        "ck_withdrawals_status",
        "withdrawals",
        "status IN ('requested', 'processing', 'successful', 'failed', 'reversed')",
    )
    op.execute(_TRIGGER_FUNCTION)
    op.execute(_TRIGGER)


def downgrade():
    op.execute("DROP TRIGGER IF EXISTS trg_withdrawal_status_transition ON withdrawals")
    op.execute("DROP FUNCTION IF EXISTS enforce_withdrawal_status_transition()")
    op.drop_constraint("ck_withdrawals_status", "withdrawals", type_="check")
