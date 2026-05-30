"""堆场作业记录 API - 含乐观锁预占 + 轨迹流水同步写入"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload

from app.core.database import get_db
from app.models.yard_operation_records import YardOperationRecord
from app.models.yard_container_inventory import YardContainerInventory
from app.models.yard_slots import YardSlot
from app.models.container_move_logs import ContainerMoveLog
from app.schemas.yard_operation_records import (
    OperationCreate, OperationStatusUpdate, OperationResponse,
)
from app.schemas.common import PaginatedResponse

OPTIMISTIC_LOCK_MAX_RETRIES = 3

router = APIRouter(prefix="/yard-operations", tags=["堆场作业记录"])


def _build_response(op: YardOperationRecord) -> OperationResponse:
    """将 ORM 对象转为响应体，展开 slot 位置标签和 container 信息"""
    data = OperationResponse.model_validate(op).model_dump()

    if op.original_slot:
        data["original_slot_label"] = (
            f"{op.original_slot.zone_id}区-{op.original_slot.row_num}排-{op.original_slot.col_num}位"
        )
    if op.target_slot:
        data["target_slot_label"] = (
            f"{op.target_slot.zone_id}区-{op.target_slot.row_num}排-{op.target_slot.col_num}位"
        )
    if op.container:
        data["container_info"] = f"{op.container.container_type} | {op.container.owner_company or ''}"

    return OperationResponse(**data)


@router.get("", response_model=PaginatedResponse[OperationResponse], summary="获取作业记录列表")
async def list_operations(
    page: int = Query(default=1, ge=1, description="页码"),
    page_size: int = Query(default=20, ge=1, le=1000, description="每页数量"),
    operation_type: str | None = Query(None, description="作业类型: shift/land/pick/flip/inspect"),
    operation_status: str | None = Query(None, description="作业状态"),
    container_id: str | None = Query(None, description="按箱号过滤"),
    db: AsyncSession = Depends(get_db),
):
    """分页查询作业记录，支持按类型、状态、箱号过滤"""

    conditions = []
    if operation_type:
        conditions.append(YardOperationRecord.operation_type == operation_type)
    if operation_status:
        conditions.append(YardOperationRecord.operation_status == operation_status)
    if container_id:
        conditions.append(YardOperationRecord.container_id == container_id)

    count_query = select(func.count()).select_from(YardOperationRecord)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    offset = (page - 1) * page_size
    query = (
        select(YardOperationRecord)
        .options(
            selectinload(YardOperationRecord.container),
            selectinload(YardOperationRecord.original_slot),
            selectinload(YardOperationRecord.target_slot),
        )
        .order_by(YardOperationRecord.created_at.desc())
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


@router.get("/{record_id}", response_model=OperationResponse, summary="获取作业记录详情")
async def get_operation(record_id: str, db: AsyncSession = Depends(get_db)):
    """根据记录号查询单条作业记录"""
    query = (
        select(YardOperationRecord)
        .options(
            selectinload(YardOperationRecord.container),
            selectinload(YardOperationRecord.original_slot),
            selectinload(YardOperationRecord.target_slot),
        )
        .where(YardOperationRecord.record_id == record_id)
    )
    result = await db.execute(query)
    op = result.scalar_one_or_none()
    if not op:
        raise HTTPException(status_code=404, detail=f"作业记录 {record_id} 不存在")
    return _build_response(op)


@router.post("", response_model=OperationResponse, status_code=201, summary="新增作业记录（联动更新台账和箱位）")
async def create_operation(data: OperationCreate, db: AsyncSession = Depends(get_db)):
    """创建作业记录，并在同一事务中联动更新：
    1. 释放原箱位 (yard_slots → empty)
    2. 占用目标箱位 (yard_slots → occupied)
    3. 更新场内台账位置 (yard_container_inventory: previous_slot_id → current_slot_id)
    """
    existing = await db.get(YardOperationRecord, data.record_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"作业记录 {data.record_id} 已存在")

    try:
        # Step 1: 插入作业记录
        op = YardOperationRecord(**data.model_dump())
        db.add(op)

        # Step 2: 释放原箱位 — 设为空闲，清空存放箱号
        if data.original_slot_id:
            await db.execute(
                update(YardSlot)
                .where(YardSlot.slot_id == data.original_slot_id)
                .values(slot_status="empty", current_container_id=None)
            )

        # Step 3: 占用目标箱位 — 设为已占用，记录当前箱号
        if data.target_slot_id:
            await db.execute(
                update(YardSlot)
                .where(YardSlot.slot_id == data.target_slot_id)
                .values(slot_status="occupied", current_container_id=data.container_id)
            )

        # Step 4: 更新场内台账 — 记录位置变更
        if data.container_id:
            # 查找现有台账记录
            inv_query = select(YardContainerInventory).where(
                YardContainerInventory.container_id == data.container_id
            )
            inv_result = await db.execute(inv_query)
            inv = inv_result.scalar_one_or_none()

            if inv:
                # 将当前位置记入 previous_slot_id，更新为新位置
                inv.previous_slot_id = inv.current_slot_id
                inv.current_slot_id = data.target_slot_id
            # 如果没有台账记录则不报错（集装箱可能还未入场落箱）

        await db.flush()
        await db.refresh(op)

        query = (
            select(YardOperationRecord)
            .options(
                selectinload(YardOperationRecord.container),
                selectinload(YardOperationRecord.original_slot),
                selectinload(YardOperationRecord.target_slot),
            )
            .where(YardOperationRecord.record_id == op.record_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建作业记录失败: {str(e)}")


@router.put("/{record_id}/status", response_model=OperationResponse, summary="更新作业状态")
async def update_operation_status(
    record_id: str, data: OperationStatusUpdate, db: AsyncSession = Depends(get_db)
):
    """更新作业状态。completed 时：乐观锁预占箱位 + 写入移动流水 + 联动台账。"""
    op = await db.get(YardOperationRecord, record_id)
    if not op:
        raise HTTPException(status_code=404, detail=f"作业记录 {record_id} 不存在")

    try:
        op.operation_status = data.operation_status

        if data.operation_status == "completed":
            if not op.end_time:
                op.end_time = datetime.now()
            if op.start_time and op.end_time:
                op.duration_minutes = int((op.end_time - op.start_time).total_seconds() / 60)

            # (1) 释放原箱位
            if op.original_slot_id:
                await db.execute(
                    update(YardSlot)
                    .where(YardSlot.slot_id == op.original_slot_id)
                    .values(slot_status="empty", current_container_id=None)
                )

            # (2) 乐观锁预占目标箱位
            if op.target_slot_id:
                slot = await db.get(YardSlot, op.target_slot_id)
                if slot and slot.slot_id:
                    success = False
                    for attempt in range(1, OPTIMISTIC_LOCK_MAX_RETRIES + 1):
                        result = await db.execute(
                            update(YardSlot)
                            .where(
                                YardSlot.slot_id == op.target_slot_id,
                                YardSlot.version == slot.version,
                            )
                            .values(
                                slot_status="occupied",
                                current_container_id=op.container_id,
                                version=slot.version + 1,
                            )
                        )
                        await db.flush()
                        if result.rowcount > 0:
                            success = True
                            break
                        # 版本号已变，重新查询后重试
                        await db.refresh(slot)

                    if not success:
                        raise HTTPException(
                            status_code=409,
                            detail=f"箱位 {op.target_slot_id} 已被抢占，请重试",
                        )

            # (3) 轨迹流水同步写入
            if op.container_id:
                move_log = ContainerMoveLog(
                    container_id=op.container_id,
                    from_slot_id=op.original_slot_id,
                    to_slot_id=op.target_slot_id,
                    move_time=datetime.now(),
                    operator_name=op.operator_name,
                    operation_id=op.record_id,
                    equipment_id=op.equipment_id,
                )
                db.add(move_log)

                # 联动台账更新
                inv_query = select(YardContainerInventory).where(
                    YardContainerInventory.container_id == op.container_id
                )
                inv_result = await db.execute(inv_query)
                inv = inv_result.scalar_one_or_none()
                if inv:
                    inv.previous_slot_id = inv.current_slot_id
                    inv.current_slot_id = op.target_slot_id

        await db.flush()
        await db.refresh(op)

        query = (
            select(YardOperationRecord)
            .options(
                selectinload(YardOperationRecord.container),
                selectinload(YardOperationRecord.original_slot),
                selectinload(YardOperationRecord.target_slot),
            )
            .where(YardOperationRecord.record_id == record_id)
        )
        result = await db.execute(query)
        return _build_response(result.scalar_one())

    except HTTPException:
        await db.rollback()
        raise
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
