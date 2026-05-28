"""闸口通行记录 API - 车辆进出闸口登记与放行管理"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError

from app.core.database import get_db
from app.models.gate_io_records import GateIORecord
from app.schemas.gate_io_records import GateRecordCreate, GateRecordRelease, GateRecordResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/gate-records", tags=["闸口通行管理"])


@router.get("", response_model=PaginatedResponse[GateRecordResponse], summary="获取闸口通行记录")
async def list_gate_records(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    truck_plate: str | None = Query(None, description="按车牌过滤"),
    io_type: str | None = Query(None, description="进出类型: inbound/outbound"),
    release_status: str | None = Query(None, description="放行状态: pending/approved/rejected"),
    db: AsyncSession = Depends(get_db),
):
    conditions = []
    if truck_plate:
        conditions.append(GateIORecord.truck_plate == truck_plate)
    if io_type:
        conditions.append(GateIORecord.io_type == io_type)
    if release_status:
        conditions.append(GateIORecord.release_status == release_status)

    count_query = select(func.count()).select_from(GateIORecord)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    offset = (page - 1) * page_size
    query = select(GateIORecord).order_by(GateIORecord.created_at.desc())
    if conditions:
        query = query.where(*conditions)
    query = query.offset(offset).limit(page_size)

    result = await db.execute(query)
    items = result.scalars().all()
    return PaginatedResponse(
        items=[GateRecordResponse.model_validate(i) for i in items],
        total=total, page=page, page_size=page_size,
    )


@router.get("/{record_id}", response_model=GateRecordResponse, summary="获取通行记录详情")
async def get_gate_record(record_id: str, db: AsyncSession = Depends(get_db)):
    record = await db.get(GateIORecord, record_id)
    if not record:
        raise HTTPException(status_code=404, detail=f"通行记录 {record_id} 不存在")
    return GateRecordResponse.model_validate(record)


@router.post("", response_model=GateRecordResponse, status_code=201, summary="新增通行记录")
async def create_gate_record(data: GateRecordCreate, db: AsyncSession = Depends(get_db)):
    existing = await db.get(GateIORecord, data.record_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"通行记录 {data.record_id} 已存在")
    try:
        record = GateIORecord(**data.model_dump())
        db.add(record)
        await db.flush()
        await db.refresh(record)
        return GateRecordResponse.model_validate(record)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建通行记录失败: {str(e)}")


@router.put("/{record_id}/release", response_model=GateRecordResponse, summary="闸口放行")
async def release_gate_record(record_id: str, data: GateRecordRelease, db: AsyncSession = Depends(get_db)):
    """专用接口：放行车辆。自动记录 exit_time 并计算 pass_duration（分钟）"""
    record = await db.get(GateIORecord, record_id)
    if not record:
        raise HTTPException(status_code=404, detail=f"通行记录 {record_id} 不存在")

    try:
        record.release_status = data.release_status
        record.release_operator = data.release_operator

        # 放行时自动记录出场时间和通行时长
        if data.release_status == "approved":
            record.exit_time = datetime.now()
            if record.entry_time:
                record.pass_duration = int((record.exit_time - record.entry_time).total_seconds() / 60)

        await db.flush()
        await db.refresh(record)
        return GateRecordResponse.model_validate(record)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"放行操作失败: {str(e)}")
