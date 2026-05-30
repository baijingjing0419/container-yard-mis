"""异常告警 API"""
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from app.core.database import get_db
from app.models.alerts import Alert
from app.schemas.alerts import AlertCreate, AlertResolve, AlertResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/alerts", tags=["异常告警"])


@router.get("", response_model=PaginatedResponse[AlertResponse], summary="获取告警列表")
async def list_alerts(
    page: int = Query(default=1, ge=1), page_size: int = Query(default=20, ge=1, le=1000),
    alert_level: str | None = Query(None), alert_type: str | None = Query(None),
    is_resolved: bool | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    conds = []
    if alert_level:
        conds.append(Alert.alert_level == alert_level)
    if alert_type:
        conds.append(Alert.alert_type == alert_type)
    if is_resolved is not None:
        conds.append(Alert.is_resolved == is_resolved)

    cq = select(func.count()).select_from(Alert)
    if conds:
        cq = cq.where(*conds)
    total = (await db.execute(cq)).scalar()
    offset = (page - 1) * page_size
    q = select(Alert).order_by(Alert.created_at.desc())
    if conds:
        q = q.where(*conds)
    q = q.offset(offset).limit(page_size)
    r = await db.execute(q)
    return PaginatedResponse(items=[AlertResponse.model_validate(a) for a in r.scalars().all()], total=total, page=page, page_size=page_size)


@router.get("/{alert_id}", response_model=AlertResponse, summary="获取告警详情")
async def get_alert(alert_id: int, db: AsyncSession = Depends(get_db)):
    a = await db.get(Alert, alert_id)
    if not a:
        raise HTTPException(status_code=404, detail=f"告警 {alert_id} 不存在")
    return AlertResponse.model_validate(a)


@router.post("", response_model=AlertResponse, status_code=201, summary="触发新告警")
async def create_alert(data: AlertCreate, db: AsyncSession = Depends(get_db)):
    try:
        a = Alert(**data.model_dump())
        db.add(a)
        await db.flush(); await db.refresh(a)
        return AlertResponse.model_validate(a)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建告警失败: {str(e)}")


@router.put("/{alert_id}/resolve", response_model=AlertResponse, summary="处理/消除告警")
async def resolve_alert(alert_id: int, data: AlertResolve, db: AsyncSession = Depends(get_db)):
    """标记告警已处理，自动记录处理人和处理时间"""
    a = await db.get(Alert, alert_id)
    if not a:
        raise HTTPException(status_code=404, detail=f"告警 {alert_id} 不存在")
    try:
        a.is_resolved = True
        a.resolved_by = data.resolved_by
        a.resolved_time = datetime.now()
        a.resolution_remark = data.resolution_remark
        await db.flush(); await db.refresh(a)
        return AlertResponse.model_validate(a)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"消除告警失败: {str(e)}")
