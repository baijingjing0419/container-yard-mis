"""集装箱 API — 轨迹流水查询 (Phase 3 前端预留)"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.container_move_logs import ContainerMoveLog
from app.models.containers_master import ContainerMaster
from app.schemas.container_move_logs import MoveLogResponse
from app.schemas.containers_master import ContainerMasterResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/containers", tags=["集装箱"])


@router.get("", response_model=PaginatedResponse[ContainerMasterResponse], summary="获取集装箱主数据列表")
async def list_containers(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=1000),
    db: AsyncSession = Depends(get_db),
):
    count_q = select(func.count()).select_from(ContainerMaster)
    total = (await db.execute(count_q)).scalar()
    offset = (page - 1) * page_size
    q = select(ContainerMaster).offset(offset).limit(page_size).order_by(ContainerMaster.created_at.desc())
    result = await db.execute(q)
    return PaginatedResponse(
        items=[ContainerMasterResponse.model_validate(c) for c in result.scalars().all()],
        total=total, page=page, page_size=page_size,
    )


@router.get("/{container_id}", response_model=ContainerMasterResponse, summary="获取集装箱主数据")
async def get_container(container_id: str, db: AsyncSession = Depends(get_db)):
    master = await db.get(ContainerMaster, container_id)
    if not master:
        raise HTTPException(status_code=404, detail=f"集装箱 {container_id} 不存在")
    return ContainerMasterResponse.model_validate(master)


@router.get(
    "/{container_id}/move-logs",
    response_model=PaginatedResponse[MoveLogResponse],
    summary="获取集装箱移动轨迹",
)
async def get_container_move_logs(
    container_id: str,
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=50, ge=1, le=1000),
    db: AsyncSession = Depends(get_db),
):
    """按时间倒序返回某个集装箱的所有移动轨迹，替代原 JSON 解析方式"""
    master = await db.get(ContainerMaster, container_id)
    if not master:
        raise HTTPException(status_code=404, detail=f"集装箱 {container_id} 不存在")

    count_q = (
        select(func.count())
        .select_from(ContainerMoveLog)
        .where(ContainerMoveLog.container_id == container_id)
    )
    total = (await db.execute(count_q)).scalar()
    offset = (page - 1) * page_size
    q = (
        select(ContainerMoveLog)
        .options(
            selectinload(ContainerMoveLog.container),
            selectinload(ContainerMoveLog.from_slot),
            selectinload(ContainerMoveLog.to_slot),
        )
        .where(ContainerMoveLog.container_id == container_id)
        .order_by(ContainerMoveLog.move_time.desc())
        .offset(offset)
        .limit(page_size)
    )
    result = await db.execute(q)
    return PaginatedResponse(
        items=[MoveLogResponse.model_validate(m) for m in result.scalars().all()],
        total=total, page=page, page_size=page_size,
    )
