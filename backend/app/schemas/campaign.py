import uuid
from datetime import datetime
from pydantic import BaseModel

class CampaignTargetingCreate(BaseModel):
    target_genders: list[str] = []
    target_age_brackets: list[str] = []
    target_marital_statuses: list[str] = []
    target_income_ranges: list[str] = []
    target_religions: list[str] = []
    target_ethnicities: list[str] = []
    target_races: list[str] = []
    target_languages: list[str] = []
    target_cities: list[str] = []
    target_states: list[str] = []
    target_countries: list[str] = []
    target_industries: list[str] = []
    target_skills: list[str] = []
    target_interests: list[str] = []
    min_follower_count: int = 0
    min_avg_story_views: int = 0

class AllocationGroupCreate(BaseModel):
    action_label: str
    percentage: float

class CampaignCreate(BaseModel):
    title: str
    platform: str
    action_type: str
    tni_service_type: str
    description: str | None = None
    target_url: str | None = None
    client_budget_ngn: float
    client_price_per_action_ngn: float
    expires_at: datetime | None = None
    is_urgent: bool = False
    has_instructions: bool = False
    instructions: str | None = None
    allocation_groups: list[AllocationGroupCreate] = []
    targeting: CampaignTargetingCreate | None = None
    comment_subtype: str | None = None
    video_subtype: str | None = None

class CampaignResponse(BaseModel):
    id: uuid.UUID
    title: str
    platform: str
    action_type: str
    tni_service_type: str
    cw_task_category: str
    client_budget_kobo: int
    worker_pay_per_action_kobo: int
    slots_total: int
    slots_filled: int
    status: str
    is_urgent: bool
    created_at: datetime
    expires_at: datetime | None
    model_config = {"from_attributes": True}
