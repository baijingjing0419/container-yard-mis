"""堆场区域管理 API - 提供区域 CRUD 操作及利用率查询"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.yard_zones import YardZone
from app.models.yard_slots import YardSlot
from app.schemas.yard_zones import ZoneCreate, ZoneUpdate, ZoneResponse, ZoneWithUtilization

router = APIRouter(prefix="/yard-zones", tags=["堆场区域管理"])


async def _build_zone_response(zone: YardZone, db: AsyncSession) -> ZoneWithUtilization:
    """构建带利用率信息的区域响应，occupied_slots 从 yard_slots 实时计算"""
    count_result = await db.execute(
        select(func.count()).select_from(YardSlot)
        .where(YardSlot.zone_id == zone.zone_id, YardSlot.slot_status == "occupied")
    )
    occupied = count_result.scalar() or 0

    util_rate = round(occupied * 100.0 / zone.total_slots, 2) if zone.total_slots > 0 else 0.0
    return ZoneWithUtilization(
        zone_id=zone.zone_id,
        zone_name=zone.zone_name,
        zone_type=zone.zone_type,
        total_slots=zone.total_slots,
        occupied_slots=occupied,
        max_tier=zone.max_tier,
        status=zone.status,
        created_at=zone.created_at,
        utilization_rate=util_rate,
        empty_slots=zone.total_slots - occupied,
    )


@router.get("", response_model=list[ZoneWithUtilization], summary="获取堆场区域列表")
async def list_zones(db: AsyncSession = Depends(get_db)):
    """查询所有堆场区域，自动计算利用率和空闲箱位数"""
    result = await db.execute(select(YardZone).order_by(YardZone.zone_id))
    zones = result.scalars().all()

    result_list = []
    for zone in zones:
        result_list.append(await _build_zone_response(zone, db))
    return result_list


@router.get("/{zone_id}", response_model=ZoneWithUtilization, summary="获取区域详情")
async def get_zone(zone_id: str, db: AsyncSession = Depends(get_db)):
    """根据区域编号查询单条记录，含利用率"""
    zone = await db.get(YardZone, zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail=f"区域 {zone_id} 不存在")

    return await _build_zone_response(zone, db)


@router.post("", response_model=ZoneResponse, status_code=201, summary="新增区域")
async def create_zone(data: ZoneCreate, db: AsyncSession = Depends(get_db)):
    """创建一条新的堆场区域记录"""
    existing = await db.get(YardZone, data.zone_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"区域 {data.zone_id} 已存在")

    zone = YardZone(**data.model_dump())
    db.add(zone)
    await db.flush()
    await db.refresh(zone)
    return ZoneResponse.model_validate(zone)


@router.put("/{zone_id}", response_model=ZoneResponse, summary="更新区域信息")
async def update_zone(zone_id: str, data: ZoneUpdate, db: AsyncSession = Depends(get_db)):
    """部分更新区域信息，如修改占用数或扩容"""
    zone = await db.get(YardZone, zone_id)
    if not zone:
        raise HTTPException(status_code=404, detail=f"区域 {zone_id} 不存在")

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(zone, field, value)

    await db.flush()
    await db.refresh(zone)
    return ZoneResponse.model_validate(zone)
