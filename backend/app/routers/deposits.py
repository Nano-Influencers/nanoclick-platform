from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.payment import Deposit
from app.models.user import User
from app.services import paystack, wallet_service

router = APIRouter(prefix="/wallet/deposits", tags=["wallet"])


@router.get("/{reference}")
async def get_deposit_status(
    reference: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Deposit).where(
            Deposit.reference == reference,
            Deposit.user_id == current_user.id,
        ).with_for_update()
    )
    deposit = result.scalar_one_or_none()
    if not deposit:
        raise HTTPException(404, "Deposit not found")

    # The webhook remains the primary payment notification path. The return
    # page uses this endpoint as a safe reconciliation path when the customer
    # returns before Paystack's webhook reaches the API.
    if deposit.status == "pending":
        try:
            verified = await paystack.verify_transaction(reference)
            provider_status = verified.get("status")
            amount_kobo = int(verified.get("amount") or 0)
            currency = verified.get("currency")
            if provider_status == "success":
                if amount_kobo != deposit.amount_kobo or currency != "NGN":
                    raise HTTPException(409, "Payment amount or currency does not match the deposit")
                await wallet_service.credit(
                    db,
                    deposit.user_id,
                    deposit.amount_kobo,
                    "deposit",
                    description="Wallet top-up via Paystack",
                    reference=deposit.reference,
                )
                deposit.status = "completed"
                deposit.completed_at = datetime.utcnow()
                await db.commit()
            elif provider_status in {"failed", "abandoned"}:
                deposit.status = "failed"
                await db.commit()
        except HTTPException:
            raise
        except Exception:
            # A temporary provider/network failure should not turn a legitimate
            # pending deposit into a failed payment. The UI can retry safely.
            await db.rollback()

    return {
        "reference": deposit.reference,
        "status": deposit.status,
        "amount_ngn": deposit.amount_kobo / 100,
        "completed_at": deposit.completed_at.isoformat() if deposit.completed_at else None,
    }
