"""场内集装箱台账 API - 全生命周期管理与位置变更"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.yard_container_inventory import YardContainerInventory
from app.schemas.yard_container_inventory import (
    InventoryCreate,
    InventoryUpdate,
    InventoryLocationUpdate,
    InventoryResponse,
)
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/yard-inventory", tags=["场内集装箱台账"])


def _build_response(inv: YardContainerInventory) -> InventoryResponse:
    """将 ORM 对象转为响应体，展开关联的 ship_name 和 slot_label"""
    data = InventoryResponse.model_validate(inv).model_dump()

    if inv.ship:
        data["ship_name"] = inv.ship.ship_name
    if inv.current_slot:
        data["slot_label"] = (
            f"{inv.current_slot.zone_id}区-"
            f"{inv.current_slot.row_num}排-{inv.current_slot.col_num}位"
        )
    if inv.container:
        data["container_info"] = f"{inv.container.container_type} | {inv.voyage_no or ''}"

    return InventoryResponse(**data)


@router.get("", response_model=PaginatedResponse[InventoryResponse], summary="获取场内台账列表")
async def list_inventory(
    page: int = Query(default=1, ge=1, description="页码"),
    page_size: int = Query(default=20, ge=1, le=1000, description="每页数量"),
    container_id: str | None = Query(None, description="按箱号过滤"),
    is_overdue: bool | None = Query(None, description="是否超期"),
    alert_level: str | None = Query(None, description="预警级别: normal/warning/critical"),
    db: AsyncSession = Depends(get_db),
):
    """分页查询场内容器台账，支持按箱号、超期状态、预警级别过滤"""

    conditions = []
    if container_id:
        conditions.append(YardContainerInventory.container_id == container_id)
    if is_overdue is not None:
        conditions.append(YardContainerInventory.is_overdue == is_overdue)
    if alert_level:
        conditions.append(YardContainerInventory.alert_level == alert_level)

    # 查询总数
    count_query = select(func.count()).select_from(YardContainerInventory)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    # 分页 + 预加载关联
    offset = (page - 1) * page_size
    query = (
        select(YardContainerInventory)
        .options(
            selectinload(YardContainerInventory.container),
            selectinload(YardContainerInventory.current_slot),
            selectinload(YardContainerInventory.ship),
        )
        .order_by(YardContainerInventory.created_at.desc())
    )
    if conditions:
        query = query.where(*conditions)
    query = query.offset(offset).limit(page_size)

    result = await db.execute(query)
    items = result.scalars().all()

    return PaginatedResponse(
        items=[_build_response(i) for i in items],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{inventory_id}", response_model=InventoryResponse, summary="获取单箱台账详情")
async def get_inventory(inventory_id: int, db: AsyncSession = Depends(get_db)):
    """根据台账ID查询单条集装箱台账"""
    query = (
        select(YardContainerInventory)
        .options(
            selectinload(YardContainerInventory.container),
            selectinload(YardContainerInventory.current_slot),
            selectinload(YardContainerInventory.ship),
        )
        .where(YardContainerInventory.inventory_id == inventory_id)
    )
    result = await db.execute(query)
    inv = result.scalar_one_or_none()
    if not inv:
        raise HTTPException(status_code=404, detail=f"台账记录 {inventory_id} 不存在")
    return _build_response(inv)


@router.post("", response_model=InventoryResponse, status_code=201, summary="新增台账记录")
async def create_inventory(data: InventoryCreate, db: AsyncSession = Depends(get_db)):
    """集装箱入场落箱时创建台账记录"""
    try:
        inv = YardContainerInventory(**data.model_dump())
        db.add(inv)
        await db.flush()
        await db.refresh(inv)

        # 重新带关联查询
        query = (
            select(YardContainerInventory)
            .options(
                selectinload(YardContainerInventory.container),
                selectinload(YardContainerInventory.current_slot),
                selectinload(YardContainerInventory.ship),
            )
            .where(YardContainerInventory.inventory_id == inv.inventory_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建台账失败: {str(e)}")


@router.put("/{inventory_id}", response_model=InventoryResponse, summary="更新台账记录")
async def update_inventory(
    inventory_id: int, data: InventoryUpdate, db: AsyncSession = Depends(get_db)
):
    """全量更新台账信息"""
    inv = await db.get(YardContainerInventory, inventory_id)
    if not inv:
        raise HTTPException(status_code=404, detail=f"台账记录 {inventory_id} 不存在")

    try:
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(inv, field, value)

        await db.flush()
        await db.refresh(inv)

        query = (
            select(YardContainerInventory)
            .options(
                selectinload(YardContainerInventory.container),
                selectinload(YardContainerInventory.current_slot),
                selectinload(YardContainerInventory.ship),
            )
            .where(YardContainerInventory.inventory_id == inventory_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"更新台账失败: {str(e)}")


@router.put("/{inventory_id}/location", response_model=InventoryResponse, summary="变更台账位置")
async def update_inventory_location(
    inventory_id: int, data: InventoryLocationUpdate, db: AsyncSession = Depends(get_db)
):
    """专用接口：调箱后更新集装箱位置，自动记录上一位置"""
    inv = await db.get(YardContainerInventory, inventory_id)
    if not inv:
        raise HTTPException(status_code=404, detail=f"台账记录 {inventory_id} 不存在")

    try:
        # 将当前位置记入 previous_slot_id，再更新为新位置
        inv.previous_slot_id = inv.current_slot_id
        inv.current_slot_id = data.current_slot_id

        await db.flush()
        await db.refresh(inv)

        query = (
            select(YardContainerInventory)
            .options(
                selectinload(YardContainerInventory.container),
                selectinload(YardContainerInventory.current_slot),
                selectinload(YardContainerInventory.ship),
            )
            .where(YardContainerInventory.inventory_id == inventory_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"位置变更失败: {str(e)}")
