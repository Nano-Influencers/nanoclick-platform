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
from app.models.platform_wallet import PlatformWallet
from app.models.platform_wallet_transaction import PlatformWalletTransaction

_CATEGORY_FIELD_MAP = {
    "one_off_single":    ("daily_one_off_single_kobo",    "total_one_off_single_kobo",    "daily_one_off_single_cps"),
    "one_off_grouped":   ("daily_one_off_grouped_kobo",   "total_one_off_grouped_kobo",   "daily_one_off_grouped_cps"),
    "repeating_single":  ("daily_repeating_single_kobo",  "total_repeating_single_kobo",  "daily_repeating_single_cps"),
    "repeating_grouped": ("daily_repeating_grouped_kobo", "total_repeating_grouped_kobo", "daily_repeating_grouped_cps"),
    "trend_push":        ("daily_trend_push_kobo",        "total_trend_push_kobo",        "daily_trend_push_cps"),
    "skill_based":       ("daily_skill_based_kobo",       "total_skill_based_kobo",       "daily_skill_based_cps"),
    "unpaid":            ("daily_unpaid_kobo",             "total_unpaid_kobo",            "daily_unpaid_cps"),
}
PLATFORM_REVENUE_WALLET_KEY = "platform_revenue"


async def _lock_wallet(db: AsyncSession, user_id: uuid.UUID) -> Wallet:
    result = await db.execute(select(Wallet).where(Wallet.user_id == user_id).with_for_update())
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(status_code=404, detail="Wallet not found")
    return wallet


async def _lock_platform_revenue_wallet(db: AsyncSession) -> PlatformWallet:
    result = await db.execute(
        select(PlatformWallet)
        .where(PlatformWallet.wallet_key == PLATFORM_REVENUE_WALLET_KEY)
        .with_for_update()
    )
    wallet = result.scalar_one_or_none()
    if not wallet:
        raise HTTPException(status_code=500, detail="Platform revenue wallet is not configured")
    return wallet


async def _existing_transaction(db: AsyncSession, wallet_id: uuid.UUID, tx_type: str,
                                reference: str, amount_kobo: int, click_points: int = 0) -> Transaction | None:
    result = await db.execute(select(Transaction).where(
        Transaction.wallet_id == wallet_id,
        Transaction.type == tx_type,
        Transaction.reference == reference,
    ).with_for_update())
    existing = result.scalar_one_or_none()
    if existing:
        if existing.amount_kobo != amount_kobo or existing.click_points_awarded != click_points:
            raise HTTPException(status_code=409, detail="Conflicting transaction reference")
        return existing
    return None


async def credit(db: AsyncSession, user_id: uuid.UUID, amount_kobo: int, tx_type: str,
                 description: str = "", reference: str | None = None, click_points: int = 0) -> Transaction:
    wallet = await _lock_wallet(db, user_id)
    if reference:
        existing = await _existing_transaction(db, wallet.id, tx_type, reference, amount_kobo, click_points)
        if existing:
            return existing
    wallet.balance_kobo += amount_kobo
    wallet.click_points += click_points
    tx = Transaction(wallet_id=wallet.id, type=tx_type, amount_kobo=amount_kobo,
                     click_points_awarded=click_points, status="completed",
                     reference=reference, description=description)
    db.add(tx)
    return tx


async def debit(db: AsyncSession, user_id: uuid.UUID, amount_kobo: int, tx_type: str,
                description: str = "", reference: str | None = None) -> Transaction:
    wallet = await _lock_wallet(db, user_id)
    if reference:
        existing = await _existing_transaction(db, wallet.id, tx_type, reference, amount_kobo)
        if existing:
            return existing
    if wallet.balance_kobo < amount_kobo:
        raise HTTPException(status_code=400, detail="Insufficient balance")
    wallet.balance_kobo -= amount_kobo
    if tx_type == "withdrawal":
        wallet.total_withdrawn_kobo += amount_kobo
    tx = Transaction(wallet_id=wallet.id, type=tx_type, amount_kobo=amount_kobo,
                     status="completed", reference=reference, description=description)
    db.add(tx)
    return tx


async def lock_escrow(db: AsyncSession, user_id: uuid.UUID, amount_kobo: int,
                      reference: str | None = None) -> Transaction:
    """Lock campaign budget into escrow at campaign launch."""
    wallet = await _lock_wallet(db, user_id)
    if reference:
        existing = await _existing_transaction(db, wallet.id, "escrow_lock", reference, amount_kobo)
        if existing:
            return existing
    if wallet.balance_kobo < amount_kobo:
        raise HTTPException(status_code=400, detail="Insufficient balance to fund campaign")
    wallet.balance_kobo -= amount_kobo
    wallet.escrow_kobo += amount_kobo
    wallet.total_spent_kobo += amount_kobo
    tx = Transaction(wallet_id=wallet.id, type="escrow_lock", amount_kobo=amount_kobo,
                     status="completed", reference=reference,
                     description="Campaign budget locked in escrow")
    db.add(tx)
    return tx


async def release_escrow_to_worker(db: AsyncSession, advertiser_id: uuid.UUID, worker_id: uuid.UUID,
                                   amount_kobo: int, click_points: int, task_category: str,
                                   reference: str | None = None,
                                   client_charge_kobo: int | None = None) -> tuple[Transaction, Transaction]:
    """Settle one approved action from advertiser escrow.

    The advertiser is charged the client price, the worker receives the worker
    payout, and the difference is recorded in the platform revenue wallet.
    """
    if amount_kobo <= 0:
        raise HTTPException(status_code=400, detail="Worker payout must be positive")

    campaign = None
    if client_charge_kobo is None and reference:
        try:
            submission_id = uuid.UUID(reference)
        except ValueError:
            submission_id = None
        if submission_id:
            from app.models.task import Submission, Task
            from app.models.campaign import Campaign
            submission = (await db.execute(select(Submission).where(Submission.id == submission_id))).scalar_one_or_none()
            if submission:
                task = (await db.execute(select(Task).where(Task.id == submission.task_id))).scalar_one_or_none()
                if task:
                    campaign = (await db.execute(
                        select(Campaign).where(Campaign.id == task.campaign_id).with_for_update()
                    )).scalar_one_or_none()
                    if campaign:
                        client_charge_kobo = campaign.client_price_per_action_kobo
                        if campaign.escrow_kobo < client_charge_kobo:
                            raise HTTPException(status_code=409, detail="Campaign escrow insufficient")

    client_charge = amount_kobo if client_charge_kobo is None else client_charge_kobo
    if client_charge <= 0:
        raise HTTPException(status_code=400, detail="Client escrow charge must be positive")
    if client_charge < amount_kobo:
        raise HTTPException(status_code=400, detail="Client charge cannot be below worker payout")

    adv_wallet = await _lock_wallet(db, advertiser_id)
    if reference:
        existing = await db.execute(select(Transaction).where(
            Transaction.reference == reference,
            Transaction.type == "escrow_release",
            Transaction.wallet_id == adv_wallet.id,
        ).with_for_update())
        adv_tx = existing.scalar_one_or_none()
        if adv_tx:
            if adv_tx.amount_kobo != client_charge:
                raise HTTPException(status_code=409, detail="Conflicting escrow release reference")
            worker_result = await db.execute(select(Transaction).where(
                Transaction.reference == reference,
                Transaction.type == "task_earning",
            ).with_for_update())
            wrk_tx = worker_result.scalar_one_or_none()
            if wrk_tx:
                if wrk_tx.amount_kobo != amount_kobo or wrk_tx.click_points_awarded != click_points:
                    raise HTTPException(status_code=409, detail="Conflicting task earning reference")
                return adv_tx, wrk_tx
            raise HTTPException(status_code=409, detail="Incomplete escrow release for reference")

    if adv_wallet.escrow_kobo < client_charge:
        raise HTTPException(status_code=400, detail="Escrow balance insufficient")

    revenue_kobo = client_charge - amount_kobo
    revenue_wallet = await _lock_platform_revenue_wallet(db)
    revenue_reference = f"revenue:{reference or uuid.uuid4()}"
    if len(revenue_reference) > 120:
        revenue_reference = revenue_reference[:120]
    revenue_existing = await db.execute(select(PlatformWalletTransaction).where(
        PlatformWalletTransaction.platform_wallet_id == revenue_wallet.id,
        PlatformWalletTransaction.type == "campaign_margin",
        PlatformWalletTransaction.reference == revenue_reference,
    ).with_for_update())
    prior_revenue = revenue_existing.scalar_one_or_none()
    if prior_revenue:
        if prior_revenue.amount_kobo != revenue_kobo:
            raise HTTPException(status_code=409, detail="Conflicting campaign margin reference")
        raise HTTPException(status_code=409, detail="Incomplete escrow settlement for reference")

    adv_wallet.escrow_kobo -= client_charge
    if campaign is not None:
        campaign.escrow_kobo -= client_charge

    adv_tx = Transaction(wallet_id=adv_wallet.id, type="escrow_release", task_category=task_category,
                         amount_kobo=client_charge, status="completed", reference=reference,
                         description="Client escrow charged; worker payout and platform margin settled")
    db.add(adv_tx)

    if revenue_kobo:
        revenue_wallet.balance_kobo += revenue_kobo
        db.add(PlatformWalletTransaction(
            platform_wallet_id=revenue_wallet.id,
            type="campaign_margin",
            amount_kobo=revenue_kobo,
            balance_after_kobo=revenue_wallet.balance_kobo,
            reference=revenue_reference,
            description="Campaign client-price margin",
        ))

    wrk_wallet = await _lock_wallet(db, worker_id)
    wrk_wallet.balance_kobo += amount_kobo
    wrk_wallet.total_earned_kobo += amount_kobo
    wrk_wallet.click_points += click_points
    fields = _CATEGORY_FIELD_MAP.get(task_category)
    if fields:
        daily_k, total_k, daily_cp = fields
        setattr(wrk_wallet, daily_k, getattr(wrk_wallet, daily_k) + amount_kobo)
        setattr(wrk_wallet, total_k, getattr(wrk_wallet, total_k) + amount_kobo)
        setattr(wrk_wallet, daily_cp, getattr(wrk_wallet, daily_cp) + click_points)
    wrk_tx = Transaction(wallet_id=wrk_wallet.id, type="task_earning", task_category=task_category,
                         amount_kobo=amount_kobo, click_points_awarded=click_points,
                         status="completed", reference=reference,
                         description="Task approved — payment received")
    db.add(wrk_tx)
    return adv_tx, wrk_tx


async def refund_escrow(db: AsyncSession, advertiser_id: uuid.UUID, amount_kobo: int,
                        reference: str | None = None, description: str = "Escrow refunded") -> Transaction:
    """Refund campaign escrow and keep campaign/wallet escrow in sync."""
    if amount_kobo <= 0:
        raise HTTPException(status_code=400, detail="Refund amount must be positive")

    campaign = None
    if reference:
        prefix = reference.split(":", 1)[0]
        try:
            campaign_id = uuid.UUID(prefix)
        except ValueError:
            campaign_id = None
        if campaign_id:
            from app.models.campaign import Campaign
            campaign = (await db.execute(
                select(Campaign).where(Campaign.id == campaign_id).with_for_update()
            )).scalar_one_or_none()
            if campaign:
                if campaign.owner_id != advertiser_id:
                    raise HTTPException(status_code=403, detail="Campaign owner mismatch")
                if campaign.escrow_kobo != amount_kobo:
                    raise HTTPException(status_code=409, detail="Campaign and refund escrow amounts diverge")

    wallet = await _lock_wallet(db, advertiser_id)
    if reference:
        existing = await _existing_transaction(db, wallet.id, "escrow_release", reference, amount_kobo)
        if existing:
            return existing
    if wallet.escrow_kobo < amount_kobo:
        raise HTTPException(status_code=409, detail="Escrow balance insufficient for requested refund")

    wallet.escrow_kobo -= amount_kobo
    wallet.balance_kobo += amount_kobo
    wallet.total_spent_kobo -= amount_kobo
    if campaign is not None:
        campaign.escrow_kobo = 0
    tx = Transaction(wallet_id=wallet.id, type="escrow_release", amount_kobo=amount_kobo,
                     status="completed", reference=reference, description=description)
    db.add(tx)
    return tx
