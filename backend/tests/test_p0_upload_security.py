import uuid

import pytest
from pydantic import ValidationError

from app.schemas.task import SubmissionCreate
from app.schemas.kyc import KycSubmitRequest
from app.services import storage


def test_submission_rejects_http_proof_url():
    with pytest.raises(ValidationError):
        SubmissionCreate(proof_urls=["http://169.254.169.254/latest/meta-data/"])


def test_submission_rejects_path_traversal_proof_key():
    with pytest.raises(ValidationError):
        SubmissionCreate(proof_urls=["proofs/123/../../secret.png"])


def test_submission_accepts_worker_storage_key():
    body = SubmissionCreate(proof_urls=[f"proofs/{uuid.uuid4()}/proof.png"])
    assert body.proof_urls[0].startswith("proofs/")


def test_kyc_rejects_http_document_url():
    with pytest.raises(ValidationError):
        KycSubmitRequest(document_url="https://example.com/id.pdf")


def test_kyc_accepts_private_storage_key():
    body = KycSubmitRequest(document_url=f"kyc/{uuid.uuid4()}/document.pdf")
    assert body.document_url.startswith("kyc/")


def test_storage_key_rejects_traversal():
    with pytest.raises(ValueError):
        storage._validate_key("proofs/user/../../secret.png")


def test_storage_key_rejects_absolute_url():
    with pytest.raises(ValueError):
        storage._validate_key("https://example.com/proof.png")
