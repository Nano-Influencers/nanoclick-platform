import uuid

import pytest
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.wallet import Wallet
from app.services import wallet_service


@pytest.mark.asyncio
async def test_debit_writes_ledger_and_reduces_balance(db: AsyncSession):
    user_id = uuid.uuid4()
    wallet = Wallet(user_id=user_id, balance_kobo=100_000)
    db.add(wallet)
    await db.commit()

    tx = await wallet_service.debit(
        db,
        user_id,
        25_000,
        "withdrawal",
        reference="wdw_test_001",
    )
    await db.commit()

    await db.refresh(wallet)
    assert wallet.balance_kobo == 75_000
    assert wallet.total_withdrawn_kobo == 25_000
    assert tx.reference == "wdw_test_001"
    assert tx.amount_kobo == 25_000
    assert tx.status == "completed"


@pytest.mark.asyncio
async def test_debit_same_reference_is_idempotent(db: AsyncSession):
    user_id = uuid.uuid4()
    wallet = Wallet(user_id=user_id, balance_kobo=100_000)
    db.add(wallet)
    await db.commit()

    first = await wallet_service.debit(
        db, user_id, 25_000, "withdrawal", reference="wdw_idempotent"
    )
    await db.flush()
    second = await wallet_service.debit(
        db, user_id, 25_000, "withdrawal", reference="wdw_idempotent"
    )

    assert first.id == second.id
    await db.refresh(wallet)
    assert wallet.balance_kobo == 75_000
    assert wallet.total_withdrawn_kobo == 25_000


@pytest.mark.asyncio
async def test_debit_rejects_conflicting_reference(db: AsyncSession):
    user_id = uuid.uuid4()
    wallet = Wallet(user_id=user_id, balance_kobo=100_000)
    db.add(wallet)
    await db.commit()

    await wallet_service.debit(
        db, user_id, 25_000, "withdrawal", reference="wdw_conflict"
    )
    await db.flush()

    with pytest.raises(HTTPException) as exc:
        await wallet_service.debit(
            db, user_id, 30_000, "withdrawal", reference="wdw_conflict"
        )
    assert exc.value.status_code == 409


@pytest.mark.asyncio
async def test_concurrent_debits_cannot_overspend(db_factory):
    user_id = uuid.uuid4()
    async with db_factory() as db:
        db.add(Wallet(user_id=user_id, balance_kobo=50_000))
        await db.commit()

    async def attempt(reference: str):
        async with db_factory() as db:
            try:
                await wallet_service.debit(
                    db, user_id, 40_000, "withdrawal", reference=reference
                )
                await db.commit()
                return True
            except Exception:
                await db.rollback()
                return False

    results = await __import__("asyncio").gather(
        attempt("wdw_concurrent_1"),
        attempt("wdw_concurrent_2"),
    )

    assert sum(results) == 1

    async with db_factory() as db:
        from sqlalchemy import select

        wallet = (await db.execute(select(Wallet).where(Wallet.user_id == user_id))).scalar_one()
        assert wallet.balance_kobo == 10_000
