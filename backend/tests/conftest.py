import os

import pytest_asyncio
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

os.environ.setdefault(
    "DATABASE_URL",
    "postgresql+asyncpg://ci:ci@localhost:5432/nanoclick",
)
os.environ.setdefault("SECRET_KEY", "test-secret-key-at-least-32-characters-long")
os.environ.setdefault("APP_ENV", "test")

from app.database import Base
from app.models import *  # noqa: F401,F403
from app.models.platform_wallet import PlatformWallet


@pytest_asyncio.fixture
async def test_engine():
    # Keep the test engine scoped to the pytest event loop. The application
    # engine is module-global and reusing its asyncpg pool across pytest's
    # function-scoped loops causes "Future attached to a different loop".
    engine = create_async_engine(
        os.environ["DATABASE_URL"],
        pool_pre_ping=True,
        pool_size=5,
        max_overflow=10,
    )

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    maker = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with maker() as session:
        for wallet_key in ("platform_revenue", "reward_pool"):
            existing = (await session.execute(
                select(PlatformWallet).where(PlatformWallet.wallet_key == wallet_key)
            )).scalar_one_or_none()
            if existing is None:
                session.add(PlatformWallet(wallet_key=wallet_key, balance_kobo=0))
        await session.commit()

        await session.execute(text("""
            CREATE OR REPLACE FUNCTION prevent_financial_ledger_mutation()
            RETURNS trigger LANGUAGE plpgsql AS $
            BEGIN
                RAISE EXCEPTION 'Financial ledger rows are immutable: % on % is not permitted',
                    TG_OP, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
            END;
            $;
        """))
        await session.execute(text("""
            CREATE OR REPLACE FUNCTION validate_platform_ledger_snapshot()
            RETURNS trigger LANGUAGE plpgsql AS $
            DECLARE current_balance BIGINT;
            BEGIN
                SELECT balance_kobo INTO current_balance FROM platform_wallets WHERE id = NEW.platform_wallet_id;
                IF current_balance IS NULL THEN
                    RAISE EXCEPTION 'Platform wallet does not exist' USING ERRCODE = 'foreign_key_violation';
                END IF;
                IF NEW.balance_after_kobo <> current_balance THEN
                    RAISE EXCEPTION 'Platform ledger snapshot does not match wallet balance' USING ERRCODE = 'check_violation';
                END IF;
                RETURN NEW;
            END;
            $;
        """))
        await session.execute(text("""
            CREATE TRIGGER trg_transactions_immutable
            BEFORE UPDATE OR DELETE ON transactions
            FOR EACH ROW EXECUTE FUNCTION prevent_financial_ledger_mutation()
        """))
        await session.execute(text("""
            CREATE TRIGGER trg_platform_wallet_transactions_immutable
            BEFORE UPDATE OR DELETE ON platform_wallet_transactions
            FOR EACH ROW EXECUTE FUNCTION prevent_financial_ledger_mutation()
        """))
        await session.execute(text("""
            CREATE TRIGGER trg_platform_ledger_snapshot
            BEFORE INSERT ON platform_wallet_transactions
            FOR EACH ROW EXECUTE FUNCTION validate_platform_ledger_snapshot()
        """))
        await session.commit()

    yield engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest_asyncio.fixture
async def db(test_engine):
    # Keep a real outer transaction around each test. The session uses
    # SAVEPOINTs for its own commits, so tests can commit and inspect state
    # without leaking rows into the next test.
    async with test_engine.connect() as conn:
        transaction = await conn.begin()
        maker = async_sessionmaker(
            bind=conn,
            class_=AsyncSession,
            expire_on_commit=False,
            join_transaction_mode="create_savepoint",
        )
        try:
            async with maker() as session:
                yield session
        finally:
            await transaction.rollback()


@pytest_asyncio.fixture
async def db_factory(test_engine):
    yield async_sessionmaker(test_engine, class_=AsyncSession, expire_on_commit=False)
