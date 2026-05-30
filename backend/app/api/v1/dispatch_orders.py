"""中控调度指令 API - 提供指令下发、状态追踪与查询"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.dispatch_orders import DispatchOrder
from app.schemas.dispatch_orders import (
    DispatchCreate,
    DispatchUpdate,
    DispatchStatusUpdate,
    DispatchResponse,
)
from app.schemas.common import PaginatedResponse
from app.api.deps import RoleChecker

router = APIRouter(prefix="/dispatch-orders", tags=["中控调度指令"])


def _build_response(order: DispatchOrder) -> DispatchResponse:
    """将 ORM 对象转为响应体，展开关联的船舶和集装箱信息"""
    data = DispatchResponse.model_validate(order).model_dump()

    if order.related_ship:
        data["ship_name"] = order.related_ship.ship_name
    if order.container:
        data["container_info"] = f"{order.container.container_type} | {order.container.voyage_no}"

    return DispatchResponse(**data)


@router.get("", response_model=PaginatedResponse[DispatchResponse], summary="获取调度指令列表")
async def list_dispatch_orders(
    page: int = Query(default=1, ge=1, description="页码"),
    page_size: int = Query(default=20, ge=1, le=1000, description="每页数量"),
    execution_status: str | None = Query(None, description="按执行状态过滤"),
    order_type: str | None = Query(None, description="按指令类型过滤"),
    db: AsyncSession = Depends(get_db),
):
    """分页查询调度指令，支持按执行状态和指令类型过滤，预加载关联数据"""

    conditions = []
    if execution_status:
        conditions.append(DispatchOrder.execution_status == execution_status)
    if order_type:
        conditions.append(DispatchOrder.order_type == order_type)

    # 查询总数
    count_query = select(func.count()).select_from(DispatchOrder)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    # 分页 + 预加载
    offset = (page - 1) * page_size
    query = (
        select(DispatchOrder)
        .options(
            selectinload(DispatchOrder.related_ship),
            selectinload(DispatchOrder.container),
        )
        .order_by(DispatchOrder.created_at.desc())
    )
    if conditions:
        query = query.where(*conditions)
    query = query.offset(offset).limit(page_size)

    result = await db.execute(query)
    orders = result.scalars().all()

    return PaginatedResponse(
        items=[_build_response(o) for o in orders],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{order_id}", response_model=DispatchResponse, summary="获取调度指令详情")
async def get_dispatch_order(order_id: str, db: AsyncSession = Depends(get_db)):
    """根据指令号查询单条调度指令（含关联数据）"""
    query = (
        select(DispatchOrder)
        .options(
            selectinload(DispatchOrder.related_ship),
            selectinload(DispatchOrder.container),
        )
        .where(DispatchOrder.order_id == order_id)
    )
    result = await db.execute(query)
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail=f"调度指令 {order_id} 不存在")
    return _build_response(order)


@router.post("", response_model=DispatchResponse, status_code=201, summary="下发调度指令")
async def create_dispatch_order(
    data: DispatchCreate,
    db: AsyncSession = Depends(get_db),
    _current_user = Depends(RoleChecker(["admin", "dispatcher"])),
):
    """由中控调度员下发一条新的调度指令"""
    existing = await db.get(DispatchOrder, data.order_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"调度指令 {data.order_id} 已存在")

    try:
        order = DispatchOrder(**data.model_dump())
        db.add(order)
        await db.flush()
        await db.refresh(order)

        query = (
            select(DispatchOrder)
            .options(
                selectinload(DispatchOrder.related_ship),
                selectinload(DispatchOrder.container),
            )
            .where(DispatchOrder.order_id == order.order_id)
        )
        result = await db.execute(query)
        order = result.scalar_one()
        return _build_response(order)

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"下发调度指令失败: {str(e)}")


@router.put("/{order_id}", response_model=DispatchResponse, summary="更新调度指令")
async def update_dispatch_order(
    order_id: str, data: DispatchUpdate, db: AsyncSession = Depends(get_db)
):
    """全量更新调度指令信息"""
    order = await db.get(DispatchOrder, order_id)
    if not order:
        raise HTTPException(status_code=404, detail=f"调度指令 {order_id} 不存在")

    try:
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(order, field, value)

        await db.flush()
        await db.refresh(order)

        query = (
            select(DispatchOrder)
            .options(
                selectinload(DispatchOrder.related_ship),
                selectinload(DispatchOrder.container),
            )
            .where(DispatchOrder.order_id == order_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"更新调度指令失败: {str(e)}")


@router.put("/{order_id}/status", response_model=DispatchResponse, summary="更新指令执行状态")
async def update_dispatch_status(
    order_id: str, data: DispatchStatusUpdate, db: AsyncSession = Depends(get_db)
):
    """专用接口：更新调度指令的执行状态，状态变为 completed 时自动记录完成时间"""
    order = await db.get(DispatchOrder, order_id)
    if not order:
        raise HTTPException(status_code=404, detail=f"调度指令 {order_id} 不存在")

    try:
        order.execution_status = data.execution_status

        # 状态变为 completed 时，自动记录实际完成时间
        if data.execution_status == "completed" and not order.actual_finish_time:
            order.actual_finish_time = datetime.now()

        await db.flush()
        await db.refresh(order)

        query = (
            select(DispatchOrder)
            .options(
                selectinload(DispatchOrder.related_ship),
                selectinload(DispatchOrder.container),
            )
            .where(DispatchOrder.order_id == order_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
