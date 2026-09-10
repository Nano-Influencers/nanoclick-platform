import uuid, json
from fastapi import APIRouter, Depends, Request, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user, require_worker
from app.models.user import User
from app.models.wallet import Wallet, Transaction
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


@router.get("/balance", response_model=WalletResponse)
async def get_balance(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    r = await db.execute(select(Wallet).where(Wallet.user_id == current_user.id))
    w = r.scalar_one_or_none()
    if not w: raise HTTPException(404, "Wallet not found")
    return _w(w)


@router.get("/transactions", response_model=list[TransactionResponse])
async def get_transactions(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    rw = await db.execute(select(Wallet).where(Wallet.user_id == current_user.id))
    w = rw.scalar_one_or_none()
    if not w: raise HTTPException(404, "Wallet not found")
    rt = await db.execute(select(Transaction).where(Transaction.wallet_id == w.id).order_by(Transaction.created_at.desc()).limit(100))
    return [{**{c.name: getattr(tx, c.name) for c in tx.__table__.columns}, "id": str(tx.id), "amount_ngn": tx.amount_kobo/100} for tx in rt.scalars()]


@router.get("/referral-stats")
async def referral_stats(current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    count_r = await db.execute(select(func.count(User.id)).where(User.referred_by == current_user.id))
    referral_count = count_r.scalar() or 0
    rw = await db.execute(select(Wallet).where(Wallet.user_id == current_user.id))
    w = rw.scalar_one_or_none()
    total_kobo = 0
    if w:
        sum_r = await db.execute(select(func.coalesce(func.sum(Transaction.amount_kobo), 0)).where(Transaction.wallet_id == w.id, Transaction.type == "referral_bonus"))
        total_kobo = sum_r.scalar() or 0
    return {"referral_count": referral_count, "total_referral_earnings_kobo": total_kobo, "total_referral_earnings_ngn": total_kobo / 100}


@router.post("/deposit/initialize", response_model=InitiateDepositResponse)
async def initiate_deposit(body: InitiateDepositRequest, current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)):
    if body.amount_ngn < 100: raise HTTPException(400, "Minimum deposit is ₦100")
    amount_kobo = int(body.amount_ngn * 100)
    reference = f"dep_{uuid.uuid4().hex[:16]}"
    # Create the provider reference before leaving the API. The webhook can
    # therefore reconcile against an authoritative deposit record rather than
    # trusting an email address, and retries are safe.
    wallet_result = await db.execute(select(Wallet).where(Wallet.user_id == current_user.id).with_for_update())
    wallet = wallet_result.scalar_one_or_none()
    if not wallet: raise HTTPException(404, "Wallet not found")
    db.add(Transaction(wallet_id=wallet.id, type="deposit", amount_kobo=amount_kobo, status="pending", reference=reference, description="Paystack wallet top-up"))
    await db.commit()
    try:
        data = await paystack.initialize_transaction(current_user.email, amount_kobo, reference)
    except Exception:
        # Leave the provider reference as a failed audit record; it cannot be
        # credited by a webhook unless Paystack actually accepts the payment.
        result = await db.execute(select(Transaction).where(Transaction.reference == reference, Transaction.type == "deposit"))
        tx = result.scalar_one_or_none()
        if tx: tx.status = "failed"
        await db.commit()
        raise HTTPException(502, "Unable to initialize payment. Please try again.")
    return InitiateDepositResponse(authorization_url=data["authorization_url"], reference=reference)


@router.get("/resolve-account", response_model=ResolveAccountResponse)
async def resolve_account(bank_code: str, account_number: str, current_user: User = Depends(require_worker)):
    try:
        data = await paystack.resolve_account_number(account_number, bank_code)
    except Exception:
        raise HTTPException(400, "Could not verify that account number/bank combination")
    return ResolveAccountResponse(account_number=data["account_number"], account_name=data["account_name"], bank_code=bank_code)


@router.post("/withdraw")
async def withdraw(body: WithdrawRequest, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    if body.amount_ngn < 500: raise HTTPException(400, "Minimum withdrawal is ₦500")
    amount_kobo = int(body.amount_ngn * 100)
    try:
        resolved = await paystack.resolve_account_number(body.account_number, body.bank_code)
    except Exception:
        raise HTTPException(400, "Could not verify that account number/bank combination")
    reference = f"wdw_{uuid.uuid4().hex[:16]}"
    await wallet_service.debit(db, current_user.id, amount_kobo, "withdrawal", description=f"Withdrawal to {resolved['account_name']} ({body.account_number})", reference=reference)
    await db.commit()
    from app.workers.payout_tasks import process_withdrawal
    process_withdrawal.delay(str(current_user.id), amount_kobo, reference, body.account_number, body.bank_code, resolved["account_name"])
    return {"message": "Withdrawal initiated", "reference": reference, "account_name": resolved["account_name"]}


@router.post("/spin", response_model=SpinResultResponse)
async def spin_to_win(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    return await rewards_service.spin(db, current_user.id)


@router.post("/checkin", response_model=CheckinResultResponse)
async def daily_checkin(current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    return await rewards_service.checkin(db, current_user.id)


@router.post("/webhooks/paystack", include_in_schema=False)
async def paystack_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    raw_body = await request.body()
    sig = request.headers.get("x-paystack-signature", "")
    if not paystack.verify_webhook_signature(raw_body, sig):
        raise HTTPException(401, "Invalid webhook signature")
    try:
        event = json.loads(raw_body)
    except json.JSONDecodeError:
        raise HTTPException(400, "Invalid webhook payload")

    event_type = event.get("event")
    data = event.get("data", {})

    if event_type == "charge.success":
        reference = data.get("reference", "")
        if not reference:
            return {"status": "ignored"}
        result = await db.execute(select(Transaction).where(Transaction.type == "deposit", Transaction.reference == reference).with_for_update())
        tx = result.scalar_one_or_none()
        if tx:
            # Verify against Paystack before crediting. The signed webhook is
            # authoritative for event origin, but verification also protects
            # against malformed/replayed business data.
            try:
                verified = await paystack.verify_transaction(reference)
            except Exception:
                raise HTTPException(502, "Payment verification temporarily unavailable")
            if verified.get("status") != "success" or int(verified.get("amount", 0)) != tx.amount_kobo or verified.get("currency") != "NGN":
                raise HTTPException(400, "Payment verification failed")
            if tx.status != "completed":
                wallet = await db.get(Wallet, tx.wallet_id, with_for_update=True)
                if wallet is None: raise HTTPException(404, "Wallet not found")
                wallet.balance_kobo += tx.amount_kobo
                tx.status = "completed"
                from app.services.notification_service import notify
                await notify(db, wallet.user_id, "deposit_success", "Wallet funded", f"₦{tx.amount_kobo/100:,.2f} was added to your wallet.")
            await db.commit()

    elif event_type in ("transfer.failed", "transfer.reversed"):
        reference = data.get("reference", "")
        rt = await db.execute(select(Transaction).where(Transaction.type == "withdrawal", Transaction.reference == reference).with_for_update())
        tx = rt.scalar_one_or_none()
        if tx and tx.status == "completed":
            w = await db.get(Wallet, tx.wallet_id, with_for_update=True)
            if w:
                await wallet_service.credit(db, w.user_id, tx.amount_kobo, "withdrawal_reversal", description="Withdrawal failed at bank — funds returned", reference=f"{reference}:reversal")
                tx.status = "failed"
                from app.services.notification_service import notify
                await notify(db, w.user_id, "withdrawal_processed", "Withdrawal failed", f"₦{tx.amount_kobo/100:,.2f} was returned to your wallet.")
                await db.commit()

    elif event_type == "transfer.success":
        reference = data.get("reference", "")
        rt = await db.execute(select(Transaction).where(Transaction.type == "withdrawal", Transaction.reference == reference).with_for_update())
        tx = rt.scalar_one_or_none()
        if tx and tx.status == "completed":
            tx.status = "completed"
            w = await db.get(Wallet, tx.wallet_id)
            if w:
                from app.services.notification_service import notify
                await notify(db, w.user_id, "withdrawal_processed", "Withdrawal successful", f"₦{tx.amount_kobo/100:,.2f} has been sent to your bank account.")
                await db.commit()

    return {"status": "ok"}
