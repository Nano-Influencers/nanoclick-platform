"""
Wallet service — every balance mutation goes through here.
Uses SELECT FOR UPDATE to prevent race conditions on concurrent writes.
Every debit/credit also writes a Transaction row (double-entry ledger).
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
    "unpaid":            ("daily_unpaid_kobo",             "total_unpaid_kobo",            "daily_unpaid_cps"),
}


async def _lock_wallet(db: AsyncSession, user_id: uuid.UUID) -> Wallet:
    result = await db.execute(
        select(Wallet).where(Wallet.user_id == user_id).with_for_update()
    )
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    return wallet


async def credit(
    db: AsyncSession,
    user_id: uuid.UUID,
    amount_kobo: int,
    tx_type: str,
    description: str = "",
    reference: str | None = None,
    click_points: int = 0,
) -> Transaction:
    wallet = await _lock_wallet(db, user_id)
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
    wallet = await _lock_wallet(db, user_id)
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
    """
    Atomically move funds from advertiser escrow to worker balance.
    Called on task approval (human review or 72h auto-approve).
    """
    # Deduct from advertiser escrow
    adv_wallet = await _lock_wallet(db, advertiser_id)
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

    # Credit worker
    wrk_wallet = await _lock_wallet(db, worker_id)
    wrk_wallet.balance_kobo += amount_kobo
    wrk_wallet.total_earned_kobo += amount_kobo
    wrk_wallet.click_points += click_points

    fields = _CATEGORY_FIELD_MAP.get(task_category)
    if fields:
        daily_k, total_k, daily_cp = fields
        setattr(wrk_wallet, daily_k,  getattr(wrk_wallet, daily_k)  + amount_kobo)
        setattr(wrk_wallet, total_k,  getattr(wrk_wallet, total_k)  + amount_kobo)
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
    if wallet.escrow_kobo < amount_kobo:
        amount_kobo = wallet.escrow_kobo   # refund whatever remains
    wallet.escrow_kobo -= amount_kobo
    wallet.balance_kobo += amount_kobo
    wallet.total_spent_kobo -= amount_kobo  # reverse the spend
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
