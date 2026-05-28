"""系统日志 API"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from app.core.database import get_db
from app.models.system_logs import SystemLog
from app.schemas.system_logs import SystemLogCreate, SystemLogResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/system-logs", tags=["系统日志"])


@router.get("", response_model=PaginatedResponse[SystemLogResponse], summary="获取系统日志")
async def list_logs(
    page: int = Query(default=1, ge=1), page_size: int = Query(default=20, ge=1, le=100),
    log_type: str | None = Query(None), user_id: str | None = Query(None),
    table_name: str | None = Query(None),
    start_time: datetime | None = Query(None, description="开始时间"),
    end_time: datetime | None = Query(None, description="结束时间"),
    db: AsyncSession = Depends(get_db),
):
    conds = []
    if log_type:
        conds.append(SystemLog.log_type == log_type)
    if user_id:
        conds.append(SystemLog.user_id == user_id)
    if table_name:
        conds.append(SystemLog.table_name == table_name)
    if start_time:
        conds.append(SystemLog.created_at >= start_time)
    if end_time:
        conds.append(SystemLog.created_at <= end_time)

    cq = select(func.count()).select_from(SystemLog)
    if conds:
        cq = cq.where(*conds)
    total = (await db.execute(cq)).scalar()
    offset = (page - 1) * page_size
    q = select(SystemLog).order_by(SystemLog.created_at.desc())
    if conds:
        q = q.where(*conds)
    q = q.offset(offset).limit(page_size)
    r = await db.execute(q)
    return PaginatedResponse(items=[SystemLogResponse.model_validate(l) for l in r.scalars().all()], total=total, page=page, page_size=page_size)


@router.post("", response_model=SystemLogResponse, status_code=201, summary="手动记录日志")
async def create_log(data: SystemLogCreate, db: AsyncSession = Depends(get_db)):
    try:
        log = SystemLog(**data.model_dump())
        db.add(log)
        await db.flush(); await db.refresh(log)
        return SystemLogResponse.model_validate(log)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"记录日志失败: {str(e)}")
