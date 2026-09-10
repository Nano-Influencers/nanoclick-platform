"""
Wallet service — every balance mutation goes through here.
Uses SELECT FOR UPDATE to prevent race conditions on concurrent writes.
Every mutation writes a Transaction row and provider references are idempotent
per wallet + transaction type.
"""
import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException
from app.models.wallet import Wallet, Transaction

_CATEGORY_FIELD_MAP = {
    "one_off_single":    ("daily_one_off_single_kobo",    "total_one_off_single_kobo",    "daily_one_off_single_cps"),
    "one_off_grouped":   ("daily_one_off_grouped_kobo",   "total_one_off_grouped_kobo",   "daily_one_off_grouped_cps"),
    "repeating_single":  ("daily_repeating_single_kobo",  "total_repeating_single_kobo",  "daily_repeating_single_cps"),
    "repeating_grouped": ("daily_repeating_grouped_kobo", "total_repeating_grouped_kobo", "daily_repeating_grouped_cps"),
    "trend_push":        ("daily_trend_push_kobo",        "total_trend_push_kobo",        "daily_trend_push_cps"),
    "skill_based":       ("daily_skill_based_kobo",       "total_skill_based_kobo",       "daily_skill_based_cps"),
    "unpaid":            ("daily_unpaid_kobo",             "total_unpaid_kobo",             "daily_unpaid_cps"),
}


async def _lock_wallet(db: AsyncSession, user_id: uuid.UUID) -> Wallet:
    result = await db.execute(
        select(Wallet).where(Wallet.user_id == user_id).with_for_update()
    )
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    return wallet


async def _existing_reference(db: AsyncSession, wallet_id: uuid.UUID, tx_type: str, reference: str | None):
    if not reference:
        return None
    result = await db.execute(
        select(Transaction).where(
            Transaction.wallet_id == wallet_id,
            Transaction.type == tx_type,
            Transaction.reference == reference,
        ).limit(1)
    )
    return result.scalar_one_or_none()


async def credit(
    db: AsyncSession,
    user_id: uuid.UUID,
    amount_kobo: int,
    tx_type: str,
    description: str = "",
    reference: str | None = None,
    click_points: int = 0,
) -> Transaction:
    if amount_kobo <= 0:
        raise HTTPException(status_code=400, detail="Credit amount must be positive")
    wallet = await _lock_wallet(db, user_id)
    existing = await _existing_reference(db, wallet.id, tx_type, reference)
    if existing:
        # A pending provider transaction is completed exactly once here.
        if existing.status == "pending":
            wallet.balance_kobo += amount_kobo
            wallet.click_points += click_points
            existing.status = "completed"
        return existing

    wallet.balance_kobo += amount_kobo
    wallet.click_points += click_points
    tx = Transaction(
        wallet_id=wallet.id,
        type=tx_type,
        amount_kobo=amount_kobo,
        click_points_awarded=click_points,
        status="completed",
        reference=reference,
        description=description,
    )
    db.add(tx)
    return tx


async def debit(
    db: AsyncSession,
    user_id: uuid.UUID,
    amount_kobo: int,
    tx_type: str,
    description: str = "",
    reference: str | None = None,
) -> Transaction:
    if amount_kobo <= 0:
        raise HTTPException(status_code=400, detail="Debit amount must be positive")
    wallet = await _lock_wallet(db, user_id)
    existing = await _existing_reference(db, wallet.id, tx_type, reference)
    if existing:
        return existing
    if wallet.balance_kobo < amount_kobo:
        raise HTTPException(status_code=400, detail="Insufficient balance")
    wallet.balance_kobo -= amount_kobo
    if tx_type == "withdrawal":
        wallet.total_withdrawn_kobo += amount_kobo
    tx = Transaction(
        wallet_id=wallet.id,
        type=tx_type,
        amount_kobo=amount_kobo,
        status="completed",
        reference=reference,
        description=description,
    )
    db.add(tx)
    return tx


async def lock_escrow(
    db: AsyncSession,
    user_id: uuid.UUID,
    amount_kobo: int,
    reference: str | None = None,
) -> Transaction:
    """Lock campaign budget into escrow at campaign launch."""
    wallet = await _lock_wallet(db, user_id)
    existing = await _existing_reference(db, wallet.id, "escrow_lock", reference)
    if existing:
        return existing
    if amount_kobo <= 0:
        raise HTTPException(status_code=400, detail="Escrow amount must be positive")
    if wallet.balance_kobo < amount_kobo:
        raise HTTPException(status_code=400, detail="Insufficient balance to fund campaign")
    wallet.balance_kobo -= amount_kobo
    wallet.escrow_kobo += amount_kobo
    wallet.total_spent_kobo += amount_kobo
    tx = Transaction(
        wallet_id=wallet.id,
        type="escrow_lock",
        amount_kobo=amount_kobo,
        status="completed",
        reference=reference,
        description="Campaign budget locked in escrow",
    )
    db.add(tx)
    return tx


async def release_escrow_to_worker(
    db: AsyncSession,
    advertiser_id: uuid.UUID,
    worker_id: uuid.UUID,
    amount_kobo: int,
    click_points: int,
    task_category: str,
    reference: str | None = None,
) -> tuple[Transaction, Transaction]:
    """Atomically move funds from advertiser escrow to worker balance."""
    if amount_kobo <= 0:
        raise HTTPException(status_code=400, detail="Release amount must be positive")
    adv_wallet = await _lock_wallet(db, advertiser_id)
    existing_adv = await _existing_reference(db, adv_wallet.id, "escrow_release", reference)
    if existing_adv:
        worker_wallet = await _lock_wallet(db, worker_id)
        existing_worker = await _existing_reference(db, worker_wallet.id, "task_earning", reference)
        if not existing_worker:
            raise HTTPException(status_code=409, detail="Escrow release is partially recorded; manual reconciliation required")
        return existing_adv, existing_worker

    if adv_wallet.escrow_kobo < amount_kobo:
        raise HTTPException(status_code=400, detail="Escrow balance insufficient")
    adv_wallet.escrow_kobo -= amount_kobo
    adv_tx = Transaction(
        wallet_id=adv_wallet.id,
        type="escrow_release",
        task_category=task_category,
        amount_kobo=amount_kobo,
        status="completed",
        reference=reference,
        description="Escrow released to worker on task approval",
    )
    db.add(adv_tx)

    wrk_wallet = await _lock_wallet(db, worker_id)
    if await _existing_reference(db, wrk_wallet.id, "task_earning", reference):
        raise HTTPException(status_code=409, detail="Worker payment already exists; manual reconciliation required")
    wrk_wallet.balance_kobo += amount_kobo
    wrk_wallet.total_earned_kobo += amount_kobo
    wrk_wallet.click_points += click_points

    fields = _CATEGORY_FIELD_MAP.get(task_category)
    if fields:
        daily_k, total_k, daily_cp = fields
        setattr(wrk_wallet, daily_k, getattr(wrk_wallet, daily_k) + amount_kobo)
        setattr(wrk_wallet, total_k, getattr(wrk_wallet, total_k) + amount_kobo)
        setattr(wrk_wallet, daily_cp, getattr(wrk_wallet, daily_cp) + click_points)

    wrk_tx = Transaction(
        wallet_id=wrk_wallet.id,
        type="task_earning",
        task_category=task_category,
        amount_kobo=amount_kobo,
        click_points_awarded=click_points,
        status="completed",
        reference=reference,
        description="Task approved — payment received",
    )
    db.add(wrk_tx)
    return adv_tx, wrk_tx


async def refund_escrow(
    db: AsyncSession,
    advertiser_id: uuid.UUID,
    amount_kobo: int,
    reference: str | None = None,
    description: str = "Escrow refunded",
) -> Transaction:
    """Return escrowed funds to advertiser (campaign cancelled/rejected/reported)."""
    wallet = await _lock_wallet(db, advertiser_id)
    existing = await _existing_reference(db, wallet.id, "escrow_release", reference)
    if existing:
        return existing
    if amount_kobo <= 0:
        raise HTTPException(status_code=400, detail="Refund amount must be positive")
    if wallet.escrow_kobo < amount_kobo:
        amount_kobo = wallet.escrow_kobo
    wallet.escrow_kobo -= amount_kobo
    wallet.balance_kobo += amount_kobo
    wallet.total_spent_kobo -= amount_kobo
    tx = Transaction(
        wallet_id=wallet.id,
        type="escrow_release",
        amount_kobo=amount_kobo,
        status="completed",
        reference=reference,
        description=description,
    )
    db.add(tx)
    return tx
