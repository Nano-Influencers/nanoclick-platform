import json
import uuid
from fastapi import Request
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit import AuditLog


async def record(
    db: AsyncSession,
    request: Request | None,
    action: str,
    actor_user_id: uuid.UUID | None = None,
    resource_type: str | None = None,
    resource_id: str | None = None,
    metadata: dict | None = None,
) -> None:
    client = request.client if request else None
    db.add(AuditLog(
        actor_user_id=actor_user_id,
        action=action,
        resource_type=resource_type,
        resource_id=resource_id,
        ip_address=client.host if client else None,
        user_agent=(request.headers.get("user-agent", "")[:500] if request else None),
        metadata_json=json.dumps(metadata, default=str) if metadata else None,
    ))
