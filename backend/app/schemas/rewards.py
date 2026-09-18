from pydantic import BaseModel
from app.schemas.treasure import TreasureResponse
from app.schemas.gifts import GiftResponse

class RewardProgressResponse(BaseModel):
    grit_level: int
    grit_difficult_tasks_approved: int
    grit_tasks_to_next_level: int
    grit_level10_reached: bool
    grit_level10_pool_claimed: bool
    gratis_level: int
    gratis_unpaid_tasks_approved: int
    gratis_tasks_to_next_level: int
    gratis_level10_reached: bool
    gratis_level10_pool_claimed: bool
    checkin_streak: int
    last_checkin_at: str | None
    checked_in_today: bool
    next_checkin_at: str | None


class TryForFreeCampaignResponse(BaseModel):
    campaign_id: str
    title: str
    description: str | None
    platform: str
    action_type: str
    pay_kobo: int
    task_count: int

class TryForFreeResponse(BaseModel):
    active: bool
    campaigns: list[TryForFreeCampaignResponse]
    unpaid_tasks_approved: int
    gratis_level: int
    gratis_tasks_to_next_level: int

class RewardsLeaderboardEntry(BaseModel):
    rank: int
    worker_id: str
    total_score: int

class RewardsLeaderboardResponse(BaseModel):
    period: str
    top: list[RewardsLeaderboardEntry]

class RewardsDashboardResponse(BaseModel):
    progress: RewardProgressResponse
    spin_available: bool
    next_spin_at: str | None
    try_for_free: TryForFreeResponse
    treasure: TreasureResponse | None
    gifts: list[GiftResponse]
    leaderboard: RewardsLeaderboardResponse
