import uuid
from datetime import datetime
from pydantic import BaseModel

class WalletResponse(BaseModel):
    id: uuid.UUID
    balance_kobo: int
    balance_ngn: float
    escrow_kobo: int
    escrow_ngn: float
    click_points: int
    total_earned_kobo: int
    total_withdrawn_kobo: int
    total_spent_kobo: int
    daily_one_off_single_kobo: int
    daily_one_off_grouped_kobo: int
    daily_repeating_single_kobo: int
    daily_repeating_grouped_kobo: int
    daily_trend_push_kobo: int
    daily_skill_based_kobo: int
    daily_unpaid_kobo: int
    daily_one_off_single_cps: int
    daily_one_off_grouped_cps: int
    daily_repeating_single_cps: int
    daily_repeating_grouped_cps: int
    daily_trend_push_cps: int
    daily_skill_based_cps: int
    daily_unpaid_cps: int
    model_config = {"from_attributes": True}

class TransactionResponse(BaseModel):
    id: uuid.UUID
    type: str
    task_category: str | None
    amount_kobo: int
    amount_ngn: float
    click_points_awarded: int
    status: str
    description: str | None
    created_at: datetime
    model_config = {"from_attributes": True}

class InitiateDepositRequest(BaseModel):
    amount_ngn: float

class InitiateDepositResponse(BaseModel):
    authorization_url: str
    reference: str

class WithdrawRequest(BaseModel):
    amount_ngn: float
    bank_code: str
    account_number: str
