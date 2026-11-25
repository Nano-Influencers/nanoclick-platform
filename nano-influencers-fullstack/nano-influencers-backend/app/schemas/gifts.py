from datetime import datetime
from pydantic import BaseModel, Field

class GiftCreateRequest(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    description: str = Field(min_length=1)
    image_url: str | None = None
    prize_name: str = Field(min_length=1, max_length=160)
    starts_at: datetime
    ends_at: datetime
    entry_cost_points: int = Field(default=0, ge=0)
    max_winners: int = Field(default=1, ge=1)

class GiftResponse(BaseModel):
    id: str
    title: str
    description: str
    image_url: str | None
    prize_name: str
    starts_at: datetime
    ends_at: datetime
    entry_cost_points: int
    max_winners: int
    entered: bool
    status: str

class GiftEntryResponse(BaseModel):
    status: str
    campaign_id: str

class GiftWinnerResponse(BaseModel):
    campaign_id: str
    prize_name: str
    status: str
    selected_at: datetime
    fulfilled_at: datetime | None
