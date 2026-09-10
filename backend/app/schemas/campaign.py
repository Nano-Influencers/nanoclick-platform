import uuid
from datetime import datetime
from pydantic import BaseModel, Field


class CampaignTargetingCreate(BaseModel):
    target_genders: list[str] = Field(default_factory=list)
    target_age_brackets: list[str] = Field(default_factory=list)
    target_marital_statuses: list[str] = Field(default_factory=list)
    target_income_ranges: list[str] = Field(default_factory=list)
    target_religions: list[str] = Field(default_factory=list)
    target_ethnicities: list[str] = Field(default_factory=list)
    target_races: list[str] = Field(default_factory=list)
    target_languages: list[str] = Field(default_factory=list)
    target_cities: list[str] = Field(default_factory=list)
    target_states: list[str] = Field(default_factory=list)
    target_countries: list[str] = Field(default_factory=list)
    target_industries: list[str] = Field(default_factory=list)
    target_skills: list[str] = Field(default_factory=list)
    target_interests: list[str] = Field(default_factory=list)
    min_follower_count: int = Field(default=0, ge=0)
    min_avg_story_views: int = Field(default=0, ge=0)


class AllocationGroupCreate(BaseModel):
    action_label: str = Field(min_length=1, max_length=100)
    percentage: float = Field(gt=0, le=100)


class CampaignCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    platform: str = Field(min_length=1, max_length=50)
    action_type: str = Field(min_length=1, max_length=50)
    tni_service_type: str = Field(min_length=1, max_length=30)
    description: str | None = None
    target_url: str | None = None
    client_budget_ngn: float = Field(gt=0)
    client_price_per_action_ngn: float = Field(gt=0)
    expires_at: datetime | None = None
    is_urgent: bool = False
    has_instructions: bool = False
    instructions: str | None = None
    allocation_groups: list[AllocationGroupCreate] = Field(default_factory=list)
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
