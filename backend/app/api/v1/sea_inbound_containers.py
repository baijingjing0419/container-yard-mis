"""海侧进箱管理 API - 提供进箱记录 CRUD 及状态变更"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.sea_inbound_containers import SeaInboundContainer
from app.schemas.sea_inbound_containers import (
    SeaInboundCreate,
    SeaInboundUpdate,
    SeaInboundStatusUpdate,
    SeaInboundResponse,
)
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/sea-inbounds", tags=["海侧进箱管理"])


def _build_response(container: SeaInboundContainer) -> SeaInboundResponse:
    """将 ORM 对象转为响应体，展开 ship_name 和 slot 位置标签"""
    data = SeaInboundResponse.model_validate(container).model_dump()

    # 展开关联的船舶名称
    if container.ship:
        data["ship_name"] = container.ship.ship_name

    # 展开关联的目标/实际堆位标签
    if container.target_slot:
        data["target_slot_label"] = f"{container.target_slot.zone_id}区-{container.target_slot.row_num}排-{container.target_slot.col_num}位"
    if container.actual_slot:
        data["actual_slot_label"] = f"{container.actual_slot.zone_id}区-{container.actual_slot.row_num}排-{container.actual_slot.col_num}位"

    return SeaInboundResponse(**data)


@router.get("", response_model=PaginatedResponse[SeaInboundResponse], summary="获取海侧进箱列表")
async def list_sea_inbounds(
    page: int = Query(default=1, ge=1, description="页码"),
    page_size: int = Query(default=20, ge=1, le=100, description="每页数量"),
    ship_id: str | None = Query(None, description="按船名航次过滤"),
    process_status: str | None = Query(None, description="按作业状态过滤"),
    db: AsyncSession = Depends(get_db),
):
    """分页查询海侧进箱记录，支持按 ship_id 和 process_status 过滤"""

    conditions = []
    if ship_id:
        conditions.append(SeaInboundContainer.ship_id == ship_id)
    if process_status:
        conditions.append(SeaInboundContainer.process_status == process_status)

    # 查询总数
    count_query = select(func.count()).select_from(SeaInboundContainer)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    # 分页查询 + 预加载关联数据，避免 N+1 查询
    offset = (page - 1) * page_size
    query = (
        select(SeaInboundContainer)
        .options(
            selectinload(SeaInboundContainer.ship),
            selectinload(SeaInboundContainer.target_slot),
            selectinload(SeaInboundContainer.actual_slot),
        )
        .order_by(SeaInboundContainer.created_at.desc())
    )
    if conditions:
        query = query.where(*conditions)
    query = query.offset(offset).limit(page_size)

    result = await db.execute(query)
    containers = result.scalars().all()

    return PaginatedResponse(
        items=[_build_response(c) for c in containers],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{container_id}", response_model=SeaInboundResponse, summary="获取进箱详情")
async def get_sea_inbound(container_id: str, db: AsyncSession = Depends(get_db)):
    """根据箱号查询单条进箱记录（含关联数据）"""
    query = (
        select(SeaInboundContainer)
        .options(
            selectinload(SeaInboundContainer.ship),
            selectinload(SeaInboundContainer.target_slot),
            selectinload(SeaInboundContainer.actual_slot),
        )
        .where(SeaInboundContainer.container_id == container_id)
    )
    result = await db.execute(query)
    container = result.scalar_one_or_none()
    if not container:
        raise HTTPException(status_code=404, detail=f"进箱记录 {container_id} 不存在")
    return _build_response(container)


@router.post("", response_model=SeaInboundResponse, status_code=201, summary="新增海侧进箱记录")
async def create_sea_inbound(data: SeaInboundCreate, db: AsyncSession = Depends(get_db)):
    """创建一条新的海侧进箱记录（模拟卸船预录入）"""
    existing = await db.get(SeaInboundContainer, data.container_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"箱号 {data.container_id} 已存在")

    try:
        container = SeaInboundContainer(**data.model_dump())
        db.add(container)
        await db.flush()
        await db.refresh(container)

        # 重新带关联查询返回
        query = (
            select(SeaInboundContainer)
            .options(
                selectinload(SeaInboundContainer.ship),
                selectinload(SeaInboundContainer.target_slot),
                selectinload(SeaInboundContainer.actual_slot),
            )
            .where(SeaInboundContainer.container_id == container.container_id)
        )
        result = await db.execute(query)
        container = result.scalar_one()
        return _build_response(container)

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建进箱记录失败: {str(e)}")


@router.put("/{container_id}", response_model=SeaInboundResponse, summary="更新进箱记录")
async def update_sea_inbound(
    container_id: str, data: SeaInboundUpdate, db: AsyncSession = Depends(get_db)
):
    """全量更新海侧进箱记录"""
    container = await db.get(SeaInboundContainer, container_id)
    if not container:
        raise HTTPException(status_code=404, detail=f"进箱记录 {container_id} 不存在")

    try:
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(container, field, value)

        await db.flush()
        await db.refresh(container)

        # 重新查询带关联
        query = (
            select(SeaInboundContainer)
            .options(
                selectinload(SeaInboundContainer.ship),
                selectinload(SeaInboundContainer.target_slot),
                selectinload(SeaInboundContainer.actual_slot),
            )
            .where(SeaInboundContainer.container_id == container_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"更新进箱记录失败: {str(e)}")


@router.put("/{container_id}/status", response_model=SeaInboundResponse, summary="更新进箱状态")
async def update_sea_inbound_status(
    container_id: str, data: SeaInboundStatusUpdate, db: AsyncSession = Depends(get_db)
):
    """专用接口：仅更新海侧进箱记录的作业状态"""
    container = await db.get(SeaInboundContainer, container_id)
    if not container:
        raise HTTPException(status_code=404, detail=f"进箱记录 {container_id} 不存在")

    try:
        container.process_status = data.process_status
        await db.flush()
        await db.refresh(container)

        query = (
            select(SeaInboundContainer)
            .options(
                selectinload(SeaInboundContainer.ship),
                selectinload(SeaInboundContainer.target_slot),
                selectinload(SeaInboundContainer.actual_slot),
            )
            .where(SeaInboundContainer.container_id == container_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
