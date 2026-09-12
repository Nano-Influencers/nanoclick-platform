import uuid

import pytest
from fastapi import HTTPException

from app.routers.admin_kyc_documents import kyc_document_url


@pytest.mark.asyncio
async def test_kyc_document_url_returns_short_lived_signed_url(monkeypatch):
    user_id = uuid.uuid4()

    class Result:
        def scalar_one_or_none(self):
            class Kyc:
                document_url = f"kyc/{user_id}/passport.pdf"
            return Kyc()

    class DB:
        async def execute(self, statement):
            return Result()

    def fake_sign(key, expires_in=300):
        assert key == f"kyc/{user_id}/passport.pdf"
        assert expires_in == 300
        return {"download_url": "signed", "expires_in_seconds": 300}

    monkeypatch.setattr("app.routers.admin_kyc_documents.generate_presigned_download_url", fake_sign)
    result = await kyc_document_url(user_id, DB(), object())
    assert result["download_url"] == "signed"


@pytest.mark.asyncio
async def test_kyc_document_url_rejects_wrong_owner_key():
    user_id = uuid.uuid4()
    other_user_id = uuid.uuid4()

    class Result:
        def scalar_one_or_none(self):
            class Kyc:
                document_url = f"kyc/{other_user_id}/passport.pdf"
            return Kyc()

    class DB:
        async def execute(self, statement):
            return Result()

    with pytest.raises(HTTPException) as exc:
        await kyc_document_url(user_id, DB(), object())
    assert exc.value.status_code == 500
