import uuid
from datetime import datetime
from pydantic import BaseModel

class TaskResponse(BaseModel):
    id: uuid.UUID
    campaign_id: uuid.UUID
    title: str
    description: str | None
    link: str | None
    platform: str
    action_type: str
    cw_task_category: str
    difficulty: str
    is_high_earning: bool
    is_urgent: bool
    pay_kobo: int
    pay_ngn: float
    slots_total: int
    slots_filled: int
    accept_timeout_minutes: int
    created_at: datetime
    model_config = {"from_attributes": True}

class AcceptTaskResponse(BaseModel):
    acceptance_id: uuid.UUID
    task_id: uuid.UUID
    expires_at: datetime
    message: str

class SubmissionCreate(BaseModel):
    proof_urls: list[str]
    proof_link: str | None = None

class SubmissionResponse(BaseModel):
    id: uuid.UUID
    task_id: uuid.UUID
    status: str
    proof_urls: list[str]
    rejection_reason: str | None
    submitted_at: datetime
    model_config = {"from_attributes": True}

class SubmissionWithTaskResponse(BaseModel):
    id: uuid.UUID
    task_id: uuid.UUID
    task_title: str
    status: str
    proof_urls: list[str]
    rejection_reason: str | None
    query_reason: str | None
    client_rating: float | None
    pay_ngn: float
    submitted_at: datetime
    reviewed_at: datetime | None

class TaskReportCreate(BaseModel):
    reason: str

class PresignedUrlRequest(BaseModel):
    file_extension: str

class PresignedUrlResponse(BaseModel):
    upload_url: str
    file_key: str
    public_url: str
    expires_in_seconds: int

class LeaderboardEntryResponse(BaseModel):
    rank: int
    worker_id: uuid.UUID
    full_name: str
    total_score: float
    ts_score: float
    cr_score: float
    ar_score: float
    tq_score: float
    td_score: float
