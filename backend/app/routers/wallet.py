import uuid, json
from fastapi import APIRouter, Depends, Request, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import get_current_user, require_worker
from app.models.user import User
from app.models.wallet import Wallet, Transaction
from app.schemas.wallet import WalletResponse, TransactionResponse, InitiateDepositRequest, InitiateDepositResponse, WithdrawRequest
from app.services import wallet_service, paystack

router = APIRouter(prefix="/wallet", tags=["wallet"])

def _w(wallet):
    d = {c.name: getattr(wallet, c.name) for c in wallet.__table__.columns}
    d["id"] = str(wallet.id)
    d["balance_ngn"] = wallet.balance_kobo / 100
    d["escrow_ngn"]  = wallet.escrow_kobo / 100
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

@router.post("/deposit/initialize", response_model=InitiateDepositResponse)
async def initiate_deposit(body: InitiateDepositRequest, current_user: User = Depends(get_current_user)):
    if body.amount_ngn < 100: raise HTTPException(400, "Minimum deposit is ₦100")
    reference = f"dep_{uuid.uuid4().hex[:16]}"
    data = await paystack.initialize_transaction(current_user.email, int(body.amount_ngn * 100), reference)
    return InitiateDepositResponse(authorization_url=data["authorization_url"], reference=reference)

@router.post("/withdraw")
async def withdraw(body: WithdrawRequest, current_user: User = Depends(require_worker), db: AsyncSession = Depends(get_db)):
    if body.amount_ngn < 500: raise HTTPException(400, "Minimum withdrawal is ₦500")
    amount_kobo = int(body.amount_ngn * 100)
    reference = f"wdw_{uuid.uuid4().hex[:16]}"
    await wallet_service.debit(db, current_user.id, amount_kobo, "withdrawal", description=f"Withdrawal to {body.account_number}", reference=reference)
    from app.workers.payout_tasks import process_withdrawal
    process_withdrawal.delay(str(current_user.id), amount_kobo, reference, body.account_number)
    return {"message": "Withdrawal initiated", "reference": reference}

@router.post("/webhooks/paystack", include_in_schema=False)
async def paystack_webhook(request: Request, db: AsyncSession = Depends(get_db)):
    raw_body = await request.body()
    sig = request.headers.get("x-paystack-signature", "")
    if not paystack.verify_webhook_signature(raw_body, sig):
        return {"status": "ignored"}
    try:
        event = json.loads(raw_body)
    except json.JSONDecodeError:
        return {"status": "invalid_json"}
    if event.get("event") == "charge.success":
        data = event["data"]
        reference  = data.get("reference", "")
        amount_kobo = data.get("amount", 0)
        email = data.get("customer", {}).get("email", "")
        if email and amount_kobo:
            result = await db.execute(select(User).where(User.email == email))
            user = result.scalar_one_or_none()
            if user:
                await wallet_service.credit(db, user.id, amount_kobo, "deposit", description="Wallet top-up via Paystack", reference=reference)
    return {"status": "ok"}
