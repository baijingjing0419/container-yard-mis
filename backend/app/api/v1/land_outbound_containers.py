"""陆侧出场管理 API"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.land_outbound_containers import LandOutboundContainer
from app.schemas.land_outbound_containers import (
    LandOutboundCreate, LandOutboundStatusUpdate, LandOutboundResponse,
)
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/land-outbounds", tags=["陆侧出场管理"])


def _build_response(c: LandOutboundContainer) -> LandOutboundResponse:
    data = LandOutboundResponse.model_validate(c).model_dump()
    if c.ship:
        data["ship_name"] = c.ship.ship_name
    if c.original_slot:
        data["slot_label"] = f"{c.original_slot.zone_id}区-{c.original_slot.row_num}排-{c.original_slot.col_num}位"
    return LandOutboundResponse(**data)


@router.get("", response_model=PaginatedResponse[LandOutboundResponse], summary="获取陆侧出场列表")
async def list_land_outbounds(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    truck_plate: str | None = Query(None),
    process_status: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    conditions = []
    if truck_plate:
        conditions.append(LandOutboundContainer.truck_plate == truck_plate)
    if process_status:
        conditions.append(LandOutboundContainer.process_status == process_status)

    count_query = select(func.count()).select_from(LandOutboundContainer)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    offset = (page - 1) * page_size
    query = (
        select(LandOutboundContainer)
        .options(selectinload(LandOutboundContainer.ship), selectinload(LandOutboundContainer.original_slot))
        .order_by(LandOutboundContainer.created_at.desc())
    )
    if conditions:
        query = query.where(*conditions)
    query = query.offset(offset).limit(page_size)
    result = await db.execute(query)
    items = result.scalars().all()
    return PaginatedResponse(items=[_build_response(i) for i in items], total=total, page=page, page_size=page_size)


@router.get("/{container_id}", response_model=LandOutboundResponse, summary="获取出场详情")
async def get_land_outbound(container_id: str, db: AsyncSession = Depends(get_db)):
    query = (
        select(LandOutboundContainer)
        .options(selectinload(LandOutboundContainer.ship), selectinload(LandOutboundContainer.original_slot))
        .where(LandOutboundContainer.container_id == container_id)
    )
    result = await db.execute(query)
    c = result.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail=f"出场记录 {container_id} 不存在")
    return _build_response(c)


@router.post("", response_model=LandOutboundResponse, status_code=201, summary="新增陆侧出场")
async def create_land_outbound(data: LandOutboundCreate, db: AsyncSession = Depends(get_db)):
    existing = await db.get(LandOutboundContainer, data.container_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"箱号 {data.container_id} 已存在")
    try:
        c = LandOutboundContainer(**data.model_dump())
        db.add(c)
        await db.flush()
        await db.refresh(c)
        query = (
            select(LandOutboundContainer)
            .options(selectinload(LandOutboundContainer.ship), selectinload(LandOutboundContainer.original_slot))
            .where(LandOutboundContainer.container_id == c.container_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建失败: {str(e)}")


@router.put("/{container_id}/status", response_model=LandOutboundResponse, summary="更新出场状态")
async def update_land_outbound_status(container_id: str, data: LandOutboundStatusUpdate, db: AsyncSession = Depends(get_db)):
    """更新出场状态。状态变为 released 时自动记录 exit_time"""
    c = await db.get(LandOutboundContainer, container_id)
    if not c:
        raise HTTPException(status_code=404, detail=f"出场记录 {container_id} 不存在")
    try:
        c.process_status = data.process_status
        if data.process_status == "released" and not c.exit_time:
            c.exit_time = datetime.now()
        await db.flush()
        await db.refresh(c)
        query = (
            select(LandOutboundContainer)
            .options(selectinload(LandOutboundContainer.ship), selectinload(LandOutboundContainer.original_slot))
            .where(LandOutboundContainer.container_id == container_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
