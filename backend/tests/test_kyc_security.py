import uuid

import pytest
from pydantic import ValidationError
from fastapi import HTTPException

from app.routers.kyc import validate_kyc_document_ownership
from app.schemas.kyc import KycSubmitRequest


def test_kyc_document_accepts_private_storage_key():
    payload = KycSubmitRequest(document_type="passport", document_url="kyc/123e4567/passport.pdf")
    assert payload.document_url == "kyc/123e4567/passport.pdf"


def test_kyc_document_must_belong_to_authenticated_worker():
    worker_a = uuid.uuid4()
    worker_b = uuid.uuid4()

    validate_kyc_document_ownership(worker_a, f"kyc/{worker_a}/passport.pdf")

    with pytest.raises(HTTPException) as exc:
        validate_kyc_document_ownership(worker_a, f"kyc/{worker_b}/passport.pdf")
    assert exc.value.status_code == 403


def test_kyc_document_without_file_is_allowed():
    validate_kyc_document_ownership(uuid.uuid4(), None)


@pytest.mark.parametrize(
    "document_url",
    [
        "https://example.com/identity.pdf",
        "http://example.com/identity.pdf",
        "/var/uploads/identity.pdf",
        "uploads/identity.pdf",
        "kyc/../private/identity.pdf",
        "kyc\\identity.pdf",
        "s3://bucket/identity.pdf",
    ],
)
def test_kyc_document_rejects_public_or_unsafe_storage_reference(document_url):
    with pytest.raises(ValidationError):
        KycSubmitRequest(document_type="passport", document_url=document_url)


def test_kyc_document_rejects_empty_or_oversized_key():
    with pytest.raises(ValidationError):
        KycSubmitRequest(document_url="   ")

    with pytest.raises(ValidationError):
        KycSubmitRequest(document_url="kyc/" + ("a" * 501))


def test_kyc_numeric_fields_reject_invalid_values():
    with pytest.raises(ValidationError):
        KycSubmitRequest(follower_count=-1)

    with pytest.raises(ValidationError):
        KycSubmitRequest(avg_story_views=-1)

    with pytest.raises(ValidationError):
        KycSubmitRequest(avg_engagement_rate=100.01)

    with pytest.raises(ValidationError):
        KycSubmitRequest(account_age_years=-0.1)
