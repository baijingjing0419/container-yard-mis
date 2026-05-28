"""海侧作业计划 API"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload
from app.core.database import get_db
from app.models.sea_operation_plans import SeaOperationPlan
from app.schemas.sea_operation_plans import SeaPlanCreate, SeaPlanStatusUpdate, SeaPlanResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/sea-plans", tags=["海侧作业计划"])


def _build(p: SeaOperationPlan) -> SeaPlanResponse:
    d = SeaPlanResponse.model_validate(p).model_dump()
    if p.ship:
        d["ship_name"] = p.ship.ship_name
    return SeaPlanResponse(**d)


@router.get("", response_model=PaginatedResponse[SeaPlanResponse], summary="海侧计划列表")
async def list_plans(
    page: int = Query(default=1, ge=1), page_size: int = Query(default=20, ge=1, le=100),
    plan_status: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    cq = select(func.count()).select_from(SeaOperationPlan)
    if plan_status:
        cq = cq.where(SeaOperationPlan.plan_status == plan_status)
    total = (await db.execute(cq)).scalar()
    offset = (page - 1) * page_size
    q = select(SeaOperationPlan).options(selectinload(SeaOperationPlan.ship)).order_by(SeaOperationPlan.created_at.desc())
    if plan_status:
        q = q.where(SeaOperationPlan.plan_status == plan_status)
    q = q.offset(offset).limit(page_size)
    r = await db.execute(q)
    return PaginatedResponse(items=[_build(i) for i in r.scalars().all()], total=total, page=page, page_size=page_size)


@router.get("/{plan_id}", response_model=SeaPlanResponse, summary="海侧计划详情")
async def get_plan(plan_id: str, db: AsyncSession = Depends(get_db)):
    q = select(SeaOperationPlan).options(selectinload(SeaOperationPlan.ship)).where(SeaOperationPlan.plan_id == plan_id)
    p = (await db.execute(q)).scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail=f"计划 {plan_id} 不存在")
    return _build(p)


@router.post("", response_model=SeaPlanResponse, status_code=201, summary="新增海侧计划")
async def create_plan(data: SeaPlanCreate, db: AsyncSession = Depends(get_db)):
    if await db.get(SeaOperationPlan, data.plan_id):
        raise HTTPException(status_code=409, detail=f"计划 {data.plan_id} 已存在")
    try:
        p = SeaOperationPlan(**data.model_dump())
        db.add(p)
        await db.flush(); await db.refresh(p)
        q = select(SeaOperationPlan).options(selectinload(SeaOperationPlan.ship)).where(SeaOperationPlan.plan_id == p.plan_id)
        return _build((await db.execute(q)).scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建失败: {str(e)}")


@router.put("/{plan_id}/status", response_model=SeaPlanResponse, summary="更新计划状态")
async def update_status(plan_id: str, data: SeaPlanStatusUpdate, db: AsyncSession = Depends(get_db)):
    p = await db.get(SeaOperationPlan, plan_id)
    if not p:
        raise HTTPException(status_code=404, detail=f"计划 {plan_id} 不存在")
    try:
        p.plan_status = data.plan_status
        if data.completion_rate is not None:
            p.completion_rate = data.completion_rate
        await db.flush(); await db.refresh(p)
        q = select(SeaOperationPlan).options(selectinload(SeaOperationPlan.ship)).where(SeaOperationPlan.plan_id == plan_id)
        return _build((await db.execute(q)).scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
