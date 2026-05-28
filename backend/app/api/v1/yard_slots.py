"""堆场箱位管理 API - 提供箱位查询与过滤"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.yard_slots import YardSlot
from app.schemas.yard_slots import SlotCreate, SlotResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/yard-slots", tags=["堆场箱位管理"])


@router.get("", response_model=PaginatedResponse[SlotResponse], summary="获取箱位列表")
async def list_slots(
    page: int = Query(default=1, ge=1, description="页码"),
    page_size: int = Query(default=100, ge=1, le=500, description="每页数量"),
    zone_id: str | None = Query(None, description="按区域过滤，如 A/B/C"),
    slot_status: str | None = Query(None, description="按状态过滤"),
    db: AsyncSession = Depends(get_db),
):
    """分页查询箱位列表，支持按 zone_id 和 slot_status 过滤"""

    # 构建动态查询条件
    conditions = []
    if zone_id:
        conditions.append(YardSlot.zone_id == zone_id)
    if slot_status:
        conditions.append(YardSlot.slot_status == slot_status)

    # 查询总数
    count_query = select(func.count()).select_from(YardSlot)
    if conditions:
        count_query = count_query.where(*conditions)
    total = (await db.execute(count_query)).scalar()

    # 分页查询数据
    offset = (page - 1) * page_size
    query = select(YardSlot).order_by(YardSlot.zone_id, YardSlot.row_num, YardSlot.col_num)
    if conditions:
        query = query.where(*conditions)
    query = query.offset(offset).limit(page_size)

    result = await db.execute(query)
    slots = result.scalars().all()

    return PaginatedResponse(
        items=[SlotResponse.model_validate(s) for s in slots],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{slot_id}", response_model=SlotResponse, summary="获取箱位详情")
async def get_slot(slot_id: str, db: AsyncSession = Depends(get_db)):
    """根据箱位编号查询单条记录"""
    slot = await db.get(YardSlot, slot_id)
    if not slot:
        raise HTTPException(status_code=404, detail=f"箱位 {slot_id} 不存在")
    return SlotResponse.model_validate(slot)


@router.post("", response_model=SlotResponse, status_code=201, summary="新增箱位")
async def create_slot(data: SlotCreate, db: AsyncSession = Depends(get_db)):
    """创建一条新的箱位记录"""
    existing = await db.get(YardSlot, data.slot_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"箱位 {data.slot_id} 已存在")

    slot = YardSlot(**data.model_dump())
    db.add(slot)
    await db.flush()
    await db.refresh(slot)
    return SlotResponse.model_validate(slot)
