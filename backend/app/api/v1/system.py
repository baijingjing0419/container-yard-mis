"""系统状态 API — 首次启动检测"""
from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.users import User
from app.models.yard_zones import YardZone

router = APIRouter(prefix="/system", tags=["系统状态"])


@router.get("/status", summary="系统初始化状态")
async def system_status(db: AsyncSession = Depends(get_db)):
    """检测系统是否完成初始配置：管理员是否存在、堆场是否已配置"""
    admin_count = (await db.execute(
        select(func.count()).select_from(User).where(User.role == "admin")
    )).scalar() or 0

    yard_count = (await db.execute(
        select(func.count()).select_from(YardZone)
    )).scalar() or 0

    return {
        "admin_exists": admin_count > 0,
        "yard_configured": yard_count > 0,
        "setup_required": admin_count == 0 or yard_count == 0,
    }
