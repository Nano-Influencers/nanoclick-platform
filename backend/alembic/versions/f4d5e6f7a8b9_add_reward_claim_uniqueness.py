"""enforce one reward claim per worker and reward

Revision ID: f4d5e6f7a8b9
Revises: f3c4d5e6f7a8
"""
from alembic import op

revision = "f4d5e6f7a8b9"
down_revision = "f3c4d5e6f7a8"
branch_labels = None
depends_on = None


def upgrade():
    # Remove any historical duplicates before adding the invariant.
    op.execute("""
        DELETE FROM reward_claims a
        USING reward_claims b
        WHERE a.user_id = b.user_id
          AND a.reward_key = b.reward_key
          AND a.id > b.id
    """)
    op.create_unique_constraint(
        "uq_reward_claim_user_reward",
        "reward_claims",
        ["user_id", "reward_key"],
    )


def downgrade():
    op.drop_constraint("uq_reward_claim_user_reward", "reward_claims", type_="unique")
