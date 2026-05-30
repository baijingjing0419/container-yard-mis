"""船舶管理 API - 提供船舶 CRUD 操作"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.models.ships import Ship
from app.schemas.ships import ShipCreate, ShipUpdate, ShipResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/ships", tags=["船舶管理"])


@router.get("", response_model=PaginatedResponse[ShipResponse], summary="获取船舶列表")
async def list_ships(
    page: int = Query(default=1, ge=1, description="页码"),
    page_size: int = Query(default=20, ge=1, le=1000, description="每页数量"),
    db: AsyncSession = Depends(get_db),
):
    """分页查询所有船舶，按创建时间倒序排列"""

    # 查询总数
    count_query = select(func.count()).select_from(Ship)
    total = (await db.execute(count_query)).scalar()

    # 分页查询数据
    offset = (page - 1) * page_size
    query = select(Ship).order_by(Ship.created_at.desc()).offset(offset).limit(page_size)
    result = await db.execute(query)
    ships = result.scalars().all()

    return PaginatedResponse(
        items=[ShipResponse.model_validate(s) for s in ships],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.get("/{ship_id}", response_model=ShipResponse, summary="获取船舶详情")
async def get_ship(ship_id: str, db: AsyncSession = Depends(get_db)):
    """根据船舶编号查询单条记录"""
    ship = await db.get(Ship, ship_id)
    if not ship:
        raise HTTPException(status_code=404, detail=f"船舶 {ship_id} 不存在")
    return ShipResponse.model_validate(ship)


@router.post("", response_model=ShipResponse, status_code=201, summary="新增船舶")
async def create_ship(data: ShipCreate, db: AsyncSession = Depends(get_db)):
    """创建一条新的船舶记录"""
    # 检查是否已存在
    existing = await db.get(Ship, data.ship_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"船舶 {data.ship_id} 已存在")

    ship = Ship(**data.model_dump())
    db.add(ship)
    await db.flush()  # 触发数据库默认值生成（created_at 等）
    await db.refresh(ship)
    return ShipResponse.model_validate(ship)


@router.put("/{ship_id}", response_model=ShipResponse, summary="更新船舶信息")
async def update_ship(ship_id: str, data: ShipUpdate, db: AsyncSession = Depends(get_db)):
    """部分更新船舶信息，只更新传入的字段"""
    ship = await db.get(Ship, ship_id)
    if not ship:
        raise HTTPException(status_code=404, detail=f"船舶 {ship_id} 不存在")

    # 只更新非 None 的字段
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(ship, field, value)

    await db.flush()
    await db.refresh(ship)
    return ShipResponse.model_validate(ship)


@router.delete("/{ship_id}", status_code=204, summary="删除船舶")
async def delete_ship(ship_id: str, db: AsyncSession = Depends(get_db)):
    """删除指定船舶记录"""
    ship = await db.get(Ship, ship_id)
    if not ship:
        raise HTTPException(status_code=404, detail=f"船舶 {ship_id} 不存在")
    db.delete(ship)
    await db.flush()
