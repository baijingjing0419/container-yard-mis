"""海侧出场管理 API (D2)"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload
from app.core.database import get_db
from app.models.sea_outbound_containers import SeaOutboundContainer
from app.schemas.sea_outbound_containers import SeaOutboundCreate, SeaOutboundStatusUpdate, SeaOutboundResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/sea-outbounds", tags=["海侧出场管理"])


def _build(c: SeaOutboundContainer) -> SeaOutboundResponse:
    d = SeaOutboundResponse.model_validate(c).model_dump()
    if c.ship:
        d["ship_name"] = c.ship.ship_name
    if c.original_slot:
        d["slot_label"] = f"{c.original_slot.zone_id}区-{c.original_slot.row_num}排-{c.original_slot.col_num}位"
    return SeaOutboundResponse(**d)


@router.get("", response_model=PaginatedResponse[SeaOutboundResponse], summary="获取海侧出场列表")
async def list_outbounds(
    page: int = Query(default=1, ge=1), page_size: int = Query(default=20, ge=1, le=100),
    ship_id: str | None = Query(None), process_status: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    conds = []
    if ship_id:
        conds.append(SeaOutboundContainer.ship_id == ship_id)
    if process_status:
        conds.append(SeaOutboundContainer.process_status == process_status)
    cq = select(func.count()).select_from(SeaOutboundContainer)
    if conds:
        cq = cq.where(*conds)
    total = (await db.execute(cq)).scalar()
    offset = (page - 1) * page_size
    q = select(SeaOutboundContainer).options(selectinload(SeaOutboundContainer.ship), selectinload(SeaOutboundContainer.original_slot)).order_by(SeaOutboundContainer.created_at.desc())
    if conds:
        q = q.where(*conds)
    q = q.offset(offset).limit(page_size)
    r = await db.execute(q)
    return PaginatedResponse(items=[_build(i) for i in r.scalars().all()], total=total, page=page, page_size=page_size)


@router.get("/{container_id}", response_model=SeaOutboundResponse, summary="获取出场详情")
async def get_outbound(container_id: str, db: AsyncSession = Depends(get_db)):
    q = select(SeaOutboundContainer).options(selectinload(SeaOutboundContainer.ship), selectinload(SeaOutboundContainer.original_slot)).where(SeaOutboundContainer.container_id == container_id)
    r = await db.execute(q)
    c = r.scalar_one_or_none()
    if not c:
        raise HTTPException(status_code=404, detail=f"出场记录 {container_id} 不存在")
    return _build(c)


@router.post("", response_model=SeaOutboundResponse, status_code=201, summary="新增出场记录")
async def create_outbound(data: SeaOutboundCreate, db: AsyncSession = Depends(get_db)):
    if await db.get(SeaOutboundContainer, data.container_id):
        raise HTTPException(status_code=409, detail=f"箱号 {data.container_id} 已存在")
    try:
        c = SeaOutboundContainer(**data.model_dump())
        db.add(c)
        await db.flush(); await db.refresh(c)
        q = select(SeaOutboundContainer).options(selectinload(SeaOutboundContainer.ship), selectinload(SeaOutboundContainer.original_slot)).where(SeaOutboundContainer.container_id == c.container_id)
        return _build((await db.execute(q)).scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建失败: {str(e)}")


@router.put("/{container_id}/status", response_model=SeaOutboundResponse, summary="更新出场状态")
async def update_status(container_id: str, data: SeaOutboundStatusUpdate, db: AsyncSession = Depends(get_db)):
    """状态流转。变为 loaded 时自动记录装船完成时间"""
    c = await db.get(SeaOutboundContainer, container_id)
    if not c:
        raise HTTPException(status_code=404, detail=f"出场记录 {container_id} 不存在")
    try:
        c.process_status = data.process_status
        if data.process_status == "loaded" and not c.load_complete_time:
            c.load_complete_time = datetime.now()
        await db.flush(); await db.refresh(c)
        q = select(SeaOutboundContainer).options(selectinload(SeaOutboundContainer.ship), selectinload(SeaOutboundContainer.original_slot)).where(SeaOutboundContainer.container_id == container_id)
        return _build((await db.execute(q)).scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
