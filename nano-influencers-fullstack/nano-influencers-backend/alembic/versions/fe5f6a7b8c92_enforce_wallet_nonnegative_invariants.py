"""Enforce nonnegative wallet and transaction invariants.

Revision ID: fe5f6a7b8c92
Revises: fd4e5f6a7b81
"""

from alembic import op

revision = "fe5f6a7b8c92"
down_revision = "fd4e5f6a7b81"
branch_labels = None
depends_on = None


_WALLET_COLUMNS = (
    "balance_kobo",
    "escrow_kobo",
    "click_points",
    "total_earned_kobo",
    "total_withdrawn_kobo",
    "total_spent_kobo",
    "checkin_streak",
)


def upgrade():
    # Fail closed rather than silently changing historical financial data.
    for column in _WALLET_COLUMNS:
        op.execute(
            f"""
            DO $$
            BEGIN
                IF EXISTS (SELECT 1 FROM wallets WHERE {column} < 0) THEN
                    RAISE EXCEPTION
                        'Cannot enforce nonnegative wallet invariant: negative {column} exists';
                END IF;
            END $$;
            """
        )

    op.execute(
        """
        DO $$
        BEGIN
            IF EXISTS (SELECT 1 FROM transactions WHERE amount_kobo < 0) THEN
                RAISE EXCEPTION
                    'Cannot enforce transaction amount invariant: negative amount exists';
            END IF;
            IF EXISTS (SELECT 1 FROM transactions WHERE click_points_awarded < 0) THEN
                RAISE EXCEPTION
                    'Cannot enforce transaction click-points invariant: negative value exists';
            END IF;
        END $$;
        """
    )

    op.create_check_constraint(
        "ck_wallet_balance_nonnegative",
        "wallets",
        "balance_kobo >= 0",
    )
    op.create_check_constraint(
        "ck_wallet_escrow_nonnegative",
        "wallets",
        "escrow_kobo >= 0",
    )
    op.create_check_constraint(
        "ck_wallet_click_points_nonnegative",
        "wallets",
        "click_points >= 0",
    )
    op.create_check_constraint(
        "ck_wallet_total_earned_nonnegative",
        "wallets",
        "total_earned_kobo >= 0",
    )
    op.create_check_constraint(
        "ck_wallet_total_withdrawn_nonnegative",
        "wallets",
        "total_withdrawn_kobo >= 0",
    )
    op.create_check_constraint(
        "ck_wallet_total_spent_nonnegative",
        "wallets",
        "total_spent_kobo >= 0",
    )
    op.create_check_constraint(
        "ck_wallet_checkin_streak_nonnegative",
        "wallets",
        "checkin_streak >= 0",
    )
    op.create_check_constraint(
        "ck_transaction_amount_nonnegative",
        "transactions",
        "amount_kobo >= 0",
    )
    op.create_check_constraint(
        "ck_transaction_click_points_nonnegative",
        "transactions",
        "click_points_awarded >= 0",
    )


def downgrade():
    for constraint in (
        "ck_transaction_click_points_nonnegative",
        "ck_transaction_amount_nonnegative",
    ):
        op.drop_constraint(constraint, "transactions", type_="check")

    for constraint in (
        "ck_wallet_checkin_streak_nonnegative",
        "ck_wallet_total_spent_nonnegative",
        "ck_wallet_total_withdrawn_nonnegative",
        "ck_wallet_total_earned_nonnegative",
        "ck_wallet_click_points_nonnegative",
        "ck_wallet_escrow_nonnegative",
        "ck_wallet_balance_nonnegative",
    ):
        op.drop_constraint(constraint, "wallets", type_="check")
