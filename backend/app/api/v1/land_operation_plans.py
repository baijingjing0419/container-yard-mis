"""陆侧作业计划 API"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from app.core.database import get_db
from app.models.land_operation_plans import LandOperationPlan
from app.schemas.land_operation_plans import LandPlanCreate, LandPlanStatusUpdate, LandPlanResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/land-plans", tags=["陆侧作业计划"])


@router.get("", response_model=PaginatedResponse[LandPlanResponse], summary="陆侧计划列表")
async def list_plans(
    page: int = Query(default=1, ge=1), page_size: int = Query(default=20, ge=1, le=1000),
    plan_status: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    cq = select(func.count()).select_from(LandOperationPlan)
    if plan_status:
        cq = cq.where(LandOperationPlan.plan_status == plan_status)
    total = (await db.execute(cq)).scalar()
    offset = (page - 1) * page_size
    q = select(LandOperationPlan).order_by(LandOperationPlan.created_at.desc())
    if plan_status:
        q = q.where(LandOperationPlan.plan_status == plan_status)
    q = q.offset(offset).limit(page_size)
    r = await db.execute(q)
    return PaginatedResponse(items=[LandPlanResponse.model_validate(i) for i in r.scalars().all()], total=total, page=page, page_size=page_size)


@router.get("/{plan_id}", response_model=LandPlanResponse, summary="陆侧计划详情")
async def get_plan(plan_id: str, db: AsyncSession = Depends(get_db)):
    p = await db.get(LandOperationPlan, plan_id)
    if not p:
        raise HTTPException(status_code=404, detail=f"计划 {plan_id} 不存在")
    return LandPlanResponse.model_validate(p)


@router.post("", response_model=LandPlanResponse, status_code=201, summary="新增陆侧计划")
async def create_plan(data: LandPlanCreate, db: AsyncSession = Depends(get_db)):
    if await db.get(LandOperationPlan, data.plan_id):
        raise HTTPException(status_code=409, detail=f"计划 {data.plan_id} 已存在")
    try:
        p = LandOperationPlan(**data.model_dump())
        db.add(p)
        await db.flush(); await db.refresh(p)
        return LandPlanResponse.model_validate(p)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建失败: {str(e)}")


@router.put("/{plan_id}/status", response_model=LandPlanResponse, summary="更新计划状态")
async def update_status(plan_id: str, data: LandPlanStatusUpdate, db: AsyncSession = Depends(get_db)):
    p = await db.get(LandOperationPlan, plan_id)
    if not p:
        raise HTTPException(status_code=404, detail=f"计划 {plan_id} 不存在")
    try:
        p.plan_status = data.plan_status
        if data.completion_rate is not None:
            p.completion_rate = data.completion_rate
        await db.flush(); await db.refresh(p)
        return LandPlanResponse.model_validate(p)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
