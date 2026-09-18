from datetime import datetime
from pydantic import BaseModel, Field

class TreasureCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=160)
    details: str = Field(min_length=1)
    image_url: str | None = None
    starts_at: datetime
    ends_at: datetime
    hint_options: list[str] = Field(default_factory=list)
    claim_code: str = Field(min_length=1, max_length=200)
    reward_kobo: int = Field(default=0, ge=0)
    reward_click_points: int = Field(default=0, ge=0)
    max_winners: int = Field(default=1, ge=1)

class TreasureClaimRequest(BaseModel):
    claim_code: str = Field(min_length=1, max_length=200)

class TreasureResponse(BaseModel):
    id: str
    name: str
    details: str
    image_url: str | None
    starts_at: datetime
    ends_at: datetime
    status: str
    reward_kobo: int
    reward_click_points: int
    max_winners: int
    participation: dict

class TreasureHintResponse(BaseModel):
    hint: str
    next_hint_at: datetime | None
    spent_earnings_kobo: int
    spent_points: int
