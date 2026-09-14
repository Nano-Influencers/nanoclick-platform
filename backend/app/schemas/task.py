import uuid
from datetime import datetime
from pydantic import BaseModel, Field, field_validator
from urllib.parse import urlparse


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
    # Despite the legacy field name, these are opaque private-storage keys,
    # never HTTP URLs. The API deliberately keeps the name for client compatibility.
    proof_urls: list[str] = Field(min_length=1, max_length=5)
    proof_link: str | None = Field(default=None, max_length=2048)

    @field_validator("proof_urls")
    @classmethod
    def validate_proof_keys(cls, values: list[str]) -> list[str]:
        for value in values:
            value = value.strip()
            if not value or len(value) > 500:
                raise ValueError("Invalid proof storage key")
            parsed = urlparse(value)
            if parsed.scheme or parsed.netloc or value.startswith("/") or "\\" in value:
                raise ValueError("Proofs must use private storage keys, not URLs")
            if ".." in value.split("/") or not value.startswith("proofs/"):
                raise ValueError("Proof storage key must be under the private proofs prefix")
        return values

    @field_validator("proof_link")
    @classmethod
    def validate_proof_link(cls, value: str | None) -> str | None:
        if value is None:
            return None
        parsed = urlparse(value.strip())
        if parsed.scheme not in {"http", "https"} or not parsed.netloc:
            raise ValueError("Proof link must be a valid HTTP(S) URL")
        return value.strip()


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
    file_extension: str = Field(min_length=2, max_length=5)


class PresignedUrlResponse(BaseModel):
    upload_url: str
    file_key: str
    content_type: str
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
