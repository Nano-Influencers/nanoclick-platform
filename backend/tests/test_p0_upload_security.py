import uuid

import pytest
from pydantic import ValidationError
from fastapi import HTTPException

from app.schemas.task import SubmissionCreate
from app.schemas.kyc import KycSubmitRequest
from app.services import storage
from app.routers import proofs


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


@pytest.mark.asyncio
async def test_proof_download_url_is_worker_scoped(monkeypatch):
    worker_id = uuid.uuid4()
    file_key = f"proofs/{worker_id}/proof.png"
    calls = {}

    def fake_validate(key, prefix):
        calls["validate"] = (key, prefix)
        return {"file_key": key}

    def fake_sign(key, expires_in):
        calls["sign"] = (key, expires_in)
        return {"download_url": "https://signed.example/proof", "expires_in_seconds": expires_in}

    monkeypatch.setattr(proofs, "validate_uploaded_object", fake_validate)
    monkeypatch.setattr(proofs, "generate_presigned_download_url", fake_sign)

    user = type("Worker", (), {"id": worker_id})()
    result = await proofs.get_proof_download_url(file_key=file_key, current_user=user)

    assert result["download_url"] == "https://signed.example/proof"
    assert calls["validate"] == (file_key, f"proofs/{worker_id}")
    assert calls["sign"] == (file_key, 300)


@pytest.mark.asyncio
async def test_proof_download_url_rejects_foreign_key(monkeypatch):
    worker_id = uuid.uuid4()

    def reject(_key, _prefix):
        raise ValueError("Storage object does not belong to this account")

    monkeypatch.setattr(proofs, "validate_uploaded_object", reject)
    user = type("Worker", (), {"id": worker_id})()

    with pytest.raises(HTTPException) as exc:
        await proofs.get_proof_download_url(
            file_key=f"proofs/{uuid.uuid4()}/proof.png",
            current_user=user,
        )
    assert exc.value.status_code == 403
