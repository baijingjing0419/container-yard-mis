"""系统状态 API"""
from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.users import User
from app.models.yard_zones import YardZone

router = APIRouter(prefix="/system", tags=["系统状态"])


@router.get("/status", summary="系统状态")
async def system_status(db: AsyncSession = Depends(get_db)):
    """检测堆场是否已配置"""
    yard_count = (await db.execute(
        select(func.count()).select_from(YardZone)
    )).scalar() or 0

    admin_count = (await db.execute(
        select(func.count()).select_from(User).where(User.role == "admin")
    )).scalar() or 0

    return {
        "admin_exists": admin_count > 0,
        "yard_configured": yard_count > 0,
        "setup_required": False,
    }
