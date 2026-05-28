"""陆侧进箱管理 API"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.land_inbound_containers import LandInboundContainer
from app.schemas.land_inbound_containers import (
    LandInboundCreate, LandInboundStatusUpdate, LandInboundResponse,
)
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/land-inbounds", tags=["陆侧进箱管理"])


def _build_response(c: LandInboundContainer) -> LandInboundResponse:
    data = LandInboundResponse.model_validate(c).model_dump()
    if c.ship:
        data["ship_name"] = c.ship.ship_name
    if c.target_slot:
        data["target_slot_label"] = f"{c.target_slot.zone_id}区-{c.target_slot.row_num}排-{c.target_slot.col_num}位"
    if c.actual_slot:
        data["actual_slot_label"] = f"{c.actual_slot.zone_id}区-{c.actual_slot.row_num}排-{c.actual_slot.col_num}位"
    return LandInboundResponse(**data)


@router.get("", response_model=PaginatedResponse[LandInboundResponse], summary="获取陆侧进箱列表")
async def list_land_inbounds(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    truck_plate: str | None = Query(None),
    process_status: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    conditions = []
    if truck_plate:
        conditions.append(LandInboundContainer.truck_plate == truck_plate)
    if process_status:
        conditions.append(LandInboundContainer.process_status == process_status)

    count_query = select(func.count()).select_from(LandInboundContainer)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    offset = (page - 1) * page_size
    query = (
        select(LandInboundContainer)
        .options(selectinload(LandInboundContainer.ship), selectinload(LandInboundContainer.target_slot), selectinload(LandInboundContainer.actual_slot))
        .order_by(LandInboundContainer.created_at.desc())
    )
    if conditions:
        query = query.where(*conditions)
    query = query.offset(offset).limit(page_size)
    result = await db.execute(query)
    items = result.scalars().all()
    return PaginatedResponse(items=[_build_response(i) for i in items], total=total, page=page, page_size=page_size)


@router.get("/{container_id}", response_model=LandInboundResponse, summary="获取进箱详情")
async def get_land_inbound(container_id: str, db: AsyncSession = Depends(get_db)):
    query = (
        select(LandInboundContainer)
        .options(selectinload(LandInboundContainer.ship), selectinload(LandInboundContainer.target_slot), selectinload(LandInboundContainer.actual_slot))
        .where(LandInboundContainer.container_id == container_id)
    )
    result = await db.execute(query)
    c = result.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail=f"进箱记录 {container_id} 不存在")
    return _build_response(c)


@router.post("", response_model=LandInboundResponse, status_code=201, summary="新增陆侧进箱")
async def create_land_inbound(data: LandInboundCreate, db: AsyncSession = Depends(get_db)):
    existing = await db.get(LandInboundContainer, data.container_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"箱号 {data.container_id} 已存在")
    try:
        c = LandInboundContainer(**data.model_dump())
        db.add(c)
        await db.flush()
        await db.refresh(c)
        query = (
            select(LandInboundContainer)
            .options(selectinload(LandInboundContainer.ship), selectinload(LandInboundContainer.target_slot), selectinload(LandInboundContainer.actual_slot))
            .where(LandInboundContainer.container_id == c.container_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建失败: {str(e)}")


@router.put("/{container_id}/status", response_model=LandInboundResponse, summary="更新进箱状态")
async def update_land_inbound_status(container_id: str, data: LandInboundStatusUpdate, db: AsyncSession = Depends(get_db)):
    c = await db.get(LandInboundContainer, container_id)
    if not c:
        raise HTTPException(status_code=404, detail=f"进箱记录 {container_id} 不存在")
    try:
        c.process_status = data.process_status
        await db.flush()
        await db.refresh(c)
        query = (
            select(LandInboundContainer)
            .options(selectinload(LandInboundContainer.ship), selectinload(LandInboundContainer.target_slot), selectinload(LandInboundContainer.actual_slot))
            .where(LandInboundContainer.container_id == container_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
