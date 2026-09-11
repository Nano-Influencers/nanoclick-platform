import hashlib
import json
import uuid
from datetime import datetime

from fastapi import APIRouter, Depends, Header, HTTPException, Request
from sqlalchemy import func, select
from sqlalchemy.dialects.postgresql import insert as pg_insert
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.database import get_db
from app.dependencies import get_current_user, require_worker
from app.models.payment import Deposit, PaystackEvent
from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.models.withdrawal import Withdrawal
from app.schemas.wallet import (
    WalletResponse, TransactionResponse, InitiateDepositRequest, InitiateDepositResponse,
    WithdrawRequest, ResolveAccountResponse, SpinResultResponse, CheckinResultResponse,
)
from app.services import wallet_service, paystack, rewards_service

router = APIRouter(prefix="/wallet", tags=["wallet"])


def _w(wallet):
    d = {c.name: getattr(wallet, c.name) for c in wallet.__table__.columns}
    d["id"] = str(wallet.id)
    d["balance_ngn"] = wallet.balance_kobo / 100
    d["escrow_ngn"] = wallet.escrow_kobo / 100
    return d


def _validate_idempotency_key(value: str | None) -> str | None:
    if value is None:
        return None
    key = value.strip()
    if not key:
        return None
    if len(key) > 100:
        raise HTTPException(400, "Idempotency-Key must be 100 characters or fewer")
    return key


@router.get("/balance", response_model=WalletResponse)
async def get_balance(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(Wallet).where(Wallet.user_id == current_user.id))
    w = r.scalar_one_or_none()
    if not w:
        raise HTTPException(404, "Wallet not found")
    return _w(w)


@router.get("/transactions", response_model=list[TransactionResponse])
async def get_transactions(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    rw = await db.execute(select(Wallet).where(Wallet.user_id == current_user.id))
    w = rw.scalar_one_or_none()
    if not w:
        raise HTTPException(404, "Wallet not found")
    rt = await db.execute(select(Transaction).where(Transaction.wallet_id == w.id).order_by(Transaction.created_at.desc()).limit(100))
    return [{**{c.name: getattr(tx, c.name) for c in tx.__table__.columns}, "id": str(tx.id), "amount_ngn": tx.amount_kobo / 100} for tx in rt.scalars()]


@router.get("/withdrawals")
async def get_withdrawals(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Withdrawal).where(Withdrawal.user_id == current_user.id).order_by(Withdrawal.created_at.desc()).limit(100)
    )
    return [
        {
            "id": str(w.id), "reference": w.reference, "amount_kobo": w.amount_kobo,
            "amount_ngn": w.amount_kobo / 100, "account_name": w.account_name,
            "account_number": w.account_number, "bank_code": w.bank_code,
            "status": w.status, "failure_reason": w.failure_reason,
            "created_at": w.created_at.isoformat(),
            "completed_at": w.completed_at.isoformat() if w.completed_at else None,
        }
        for w in result.scalars()
    ]


@router.get("/referral-stats")
async def referral_stats(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    count_r = await db.execute(select(func.count(User.id)).where(User.referred_by == current_user.id))
    referral_count = count_r.scalar() or 0
    rw = await db.execute(select(Wallet).where(Wallet.user_id == current_user.id))
    w = rw.scalar_one_or_none()
    total_kobo = 0
    if w:
        sum_r = await db.execute(select(func.coalesce(func.sum(Transaction.amount_kobo), 0)).where(
            Transaction.wallet_id == w.id, Transaction.type == "referral_bonus"
        ))
        total_kobo = sum_r.scalar() or 0
    return {"referral_count": referral_count, "total_referral_earnings_kobo": total_kobo, "total_referral_earnings_ngn": total_kobo / 100}


@router.post("/deposit/initialize", response_model=InitiateDepositResponse)
async def initiate_deposit(
    body: InitiateDepositRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
):
    if body.amount_ngn < 100:
        raise HTTPException(400, "Minimum deposit is ₦100")
    key = _validate_idempotency_key(idempotency_key)
    amount_kobo = int(body.amount_ngn * 100)

    if key:
        existing_result = await db.execute(select(Deposit).where(
            Deposit.user_id == current_user.id,
            Deposit.idempotency_key == key,
        ).with_for_update())
        existing = existing_result.scalar_one_or_none()
        if existing:
            if existing.amount_kobo != amount_kobo:
                raise HTTPException(409, "Idempotency-Key was already used for a different deposit amount")
            if existing.authorization_url:
                return InitiateDepositResponse(authorization_url=existing.authorization_url, reference=existing.reference)
            raise HTTPException(409, "The previous payment initialization failed; use a new Idempotency-Key")

    reference = f"dep_{uuid.uuid4().hex[:16]}"
    db.add(Deposit(
        user_id=current_user.id,
        reference=reference,
        amount_kobo=amount_kobo,
        status="pending",
        idempotency_key=key,
    ))
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        if key:
            existing_result = await db.execute(select(Deposit).where(
                Deposit.user_id == current_user.id,
                Deposit.idempotency_key == key,
            ))
            existing = existing_result.scalar_one_or_none()
            if existing and existing.amount_kobo == amount_kobo and existing.authorization_url:
                return InitiateDepositResponse(authorization_url=existing.authorization_url, reference=existing.reference)
        raise HTTPException(409, "A deposit with this Idempotency-Key already exists")

    try:
        data = await paystack.initialize_transaction(current_user.email, amount_kobo, reference)
    except Exception:
        try:
            result = await db.execute(select(Deposit).where(Deposit.reference == reference).with_for_update())
            persisted = result.scalar_one_or_none()
            if persisted and persisted.status == "pending":
                persisted.status = "failed"
                await db.commit()
        except Exception:
            await db.rollback()
        raise HTTPException(502, "Unable to initialize payment. Please try again.")

    deposit_result = await db.execute(select(Deposit).where(Deposit.reference == reference).with_for_update())
    deposit = deposit_result.scalar_one_or_none()
    if not deposit:
        raise HTTPException(500, "Deposit record disappeared during payment initialization")
    deposit.authorization_url = data["authorization_url"]
    await db.commit()
    return InitiateDepositResponse(authorization_url=data["authorization_url"], reference=reference)


@router.get("/resolve-account", response_model=ResolveAccountResponse)
async def resolve_account(bank_code: str, account_number: str, current_user: User = Depends(require_worker)):
    try:
        data = await paystack.resolve_account_number(account_number, bank_code)
    except Exception:
        raise HTTPException(400, "Could not verify that account number/bank combination")
    return ResolveAccountResponse(account_number=data["account_number"], account_name=data["account_name"], bank_code=bank_code)


@router.post("/withdraw")
async def withdraw(
    body: WithdrawRequest,
    current_user: User = Depends(require_worker),
    db: AsyncSession = Depends(get_db),
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
):
    if body.amount_ngn < 500:
        raise HTTPException(400, "Minimum withdrawal is ₦500")
    key = _validate_idempotency_key(idempotency_key)
    amount_kobo = int(body.amount_ngn * 100)

    if key:
        existing_result = await db.execute(select(Withdrawal).where(
            Withdrawal.user_id == current_user.id,
            Withdrawal.idempotency_key == key,
        ).with_for_update())
        existing = existing_result.scalar_one_or_none()
        if existing:
            if existing.amount_kobo != amount_kobo or existing.account_number != body.account_number or existing.bank_code != body.bank_code:
                raise HTTPException(409, "Idempotency-Key was already used for a different withdrawal")
            return {"message": "Withdrawal already initiated", "reference": existing.reference, "account_name": existing.account_name, "status": existing.status}

    try:
        resolved = await paystack.resolve_account_number(body.account_number, body.bank_code)
    except Exception:
        raise HTTPException(400, "Could not verify that account number/bank combination")

    reference = f"wdw_{uuid.uuid4().hex[:16]}"
    await wallet_service.debit(
        db, current_user.id, amount_kobo, "withdrawal",
        description=f"Withdrawal to {resolved['account_name']} ({body.account_number})",
        reference=reference,
    )
    db.add(Withdrawal(
        user_id=current_user.id, reference=reference, amount_kobo=amount_kobo,
        account_number=body.account_number, bank_code=body.bank_code,
        account_name=resolved["account_name"], status="requested", idempotency_key=key,
    ))
    try:
        await db.commit()
    except IntegrityError:
        await db.rollback()
        if key:
            existing_result = await db.execute(select(Withdrawal).where(
                Withdrawal.user_id == current_user.id,
                Withdrawal.idempotency_key == key,
            ))
            existing = existing_result.scalar_one_or_none()
            if existing:
                return {"message": "Withdrawal already initiated", "reference": existing.reference, "account_name": existing.account_name, "status": existing.status}
        raise HTTPException(409, "A withdrawal with this Idempotency-Key already exists")

    from app.workers.payout_tasks import process_withdrawal
    try:
        process_withdrawal.delay(str(current_user.id), amount_kobo, reference, body.account_number, body.bank_code, resolved["account_name"])
    except Exception:
        return {"message": "Withdrawal queued for processing", "reference": reference, "account_name": resolved["account_name"], "status": "requested"}
    return {"message": "Withdrawal initiated", "reference": reference, "account_name": resolved["account_name"], "status": "requested"}


@router.post("/spin", response_model=SpinResultResponse)
async def spin_to_win(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    return await rewards_service.spin(db, current_user.id)


@router.post("/checkin", response_model=CheckinResultResponse)
async def daily_checkin(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    return await rewards_service.checkin(db, current_user.id)


@router.post("/webhooks/paystack", include_in_schema=False)
async def paystack_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    raw_body = await request.body()
    signature = request.headers.get("x-paystack-signature", "")
    if not paystack.verify_webhook_signature(raw_body, signature):
        raise HTTPException(401, "Invalid webhook signature")
    try:
        event = json.loads(raw_body)
    except json.JSONDecodeError:
        raise HTTPException(400, "Invalid JSON payload")

    event_type = event.get("event")
    data = event.get("data") or {}
    reference = data.get("reference") or ""
    event_id = request.headers.get("x-paystack-event-id") or hashlib.sha256(raw_body).hexdigest()

    inserted = await db.execute(
        pg_insert(PaystackEvent).values(event_id=event_id, event_type=event_type or "unknown", reference=reference or None)
        .on_conflict_do_nothing(index_elements=["event_id"]).returning(PaystackEvent.id)
    )
    if inserted.scalar_one_or_none() is None:
        return {"status": "duplicate"}

    if event_type == "charge.success":
        amount_kobo = int(data.get("amount") or 0)
        currency = data.get("currency")
        if not reference or amount_kobo <= 0 or currency != "NGN":
            raise HTTPException(400, "Invalid payment payload")
        deposit_result = await db.execute(select(Deposit).where(Deposit.reference == reference).with_for_update())
        deposit = deposit_result.scalar_one_or_none()
        if not deposit:
            raise HTTPException(400, "Unknown deposit reference")
        if deposit.status == "completed":
            return {"status": "already_completed"}
        if deposit.status != "pending" or deposit.amount_kobo != amount_kobo:
            raise HTTPException(400, "Payment amount or state does not match deposit")
        try:
            verified = await paystack.verify_transaction(reference)
            if verified.get("status") != "success" or int(verified.get("amount") or 0) != amount_kobo or verified.get("currency") != "NGN":
                raise HTTPException(400, "Payment verification failed")
        except HTTPException:
            raise
        except Exception:
            raise HTTPException(502, "Payment verification temporarily unavailable")
        await wallet_service.credit(db, deposit.user_id, amount_kobo, "deposit", description="Wallet top-up via Paystack", reference=reference)
        deposit.status = "completed"
        deposit.completed_at = datetime.utcnow()
        from app.services.notification_service import notify
        await notify(db, deposit.user_id, "deposit_success", "Wallet funded", f"₦{amount_kobo/100:,.2f} was added to your wallet.")

    elif event_type in ("transfer.failed", "transfer.reversed"):
        rt = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
        withdrawal = rt.scalar_one_or_none()
        if withdrawal:
            event_amount = int(data.get("amount") or 0)
            if event_amount and event_amount != withdrawal.amount_kobo:
                raise HTTPException(400, "Transfer amount does not match withdrawal")

            if event_type == "transfer.failed":
                should_refund = withdrawal.status in ("requested", "processing")
                target_status = "failed"
            else:
                should_refund = withdrawal.status in ("requested", "processing", "successful")
                target_status = "reversed"

            if should_refund:
                tx_result = await db.execute(select(Transaction).where(
                    Transaction.reference == reference,
                    Transaction.type == "withdrawal",
                ).with_for_update())
                tx = tx_result.scalar_one_or_none()
                if not tx:
                    raise HTTPException(409, "Withdrawal ledger entry missing; cannot safely reverse funds")

                reversal_reference = f"{reference}:reversal"
                existing_reversal = await db.execute(select(Transaction).where(
                    Transaction.reference == reversal_reference,
                    Transaction.type == "withdrawal_reversal",
                ).with_for_update())
                if existing_reversal.scalar_one_or_none() is None:
                    await wallet_service.credit(
                        db, withdrawal.user_id, tx.amount_kobo, "withdrawal_reversal",
                        description="Withdrawal failed at bank — funds returned",
                        reference=reversal_reference,
                    )
                withdrawal.status = target_status
                withdrawal.provider_reference = data.get("transfer_code") or withdrawal.provider_reference
                withdrawal.failure_reason = data.get("reason") or ("Paystack transfer reversed" if event_type == "transfer.reversed" else "Paystack transfer failed")
                withdrawal.completed_at = datetime.utcnow()
                from app.services.notification_service import notify
                title = "Withdrawal reversed" if event_type == "transfer.reversed" else "Withdrawal failed"
                await notify(db, withdrawal.user_id, "withdrawal_processed", title, f"Your withdrawal of ₦{withdrawal.amount_kobo/100:,.2f} could not be completed and was refunded to your wallet.")

    elif event_type == "transfer.success":
        result = await db.execute(select(Withdrawal).where(Withdrawal.reference == reference).with_for_update())
        withdrawal = result.scalar_one_or_none()
        if withdrawal:
            event_amount = int(data.get("amount") or 0)
            if event_amount and event_amount != withdrawal.amount_kobo:
                raise HTTPException(400, "Transfer amount does not match withdrawal")
            if withdrawal.status not in ("successful", "failed", "reversed"):
                withdrawal.status = "successful"
                withdrawal.provider_reference = data.get("transfer_code") or withdrawal.provider_reference or reference
                withdrawal.completed_at = datetime.utcnow()
                from app.services.notification_service import notify
                await notify(db, withdrawal.user_id, "withdrawal_processed", "Withdrawal successful", f"₦{withdrawal.amount_kobo/100:,.2f} has been sent to your bank account.")

    await db.commit()
    return {"status": "ok"}
