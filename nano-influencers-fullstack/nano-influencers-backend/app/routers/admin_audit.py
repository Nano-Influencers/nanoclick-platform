from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_db
from app.dependencies import require_admin
from app.models.audit import AuditLog
from app.models.user import User

router = APIRouter(prefix="/admin/audit", tags=["admin-audit"])


@router.get("")
async def list_audit_logs(
    limit: int = 100,
    current_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    limit = max(1, min(limit, 500))
    result = await db.execute(select(AuditLog).order_by(AuditLog.created_at.desc()).limit(limit))
    return [
        {
            "id": str(log.id), "actor_user_id": str(log.actor_user_id) if log.actor_user_id else None,
            "action": log.action, "resource_type": log.resource_type, "resource_id": log.resource_id,
            "ip_address": log.ip_address, "user_agent": log.user_agent,
            "metadata": log.metadata_json, "created_at": log.created_at.isoformat(),
        }
        for log in result.scalars()
    ]
