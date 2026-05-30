"""海侧码头统筹 API (D3)"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import selectinload
from app.core.database import get_db
from app.models.sea_terminal_io import SeaTerminalIO
from app.schemas.sea_terminal_io import TerminalIOCreate, TerminalIOProgressUpdate, TerminalIOResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/sea-terminal-io", tags=["海侧码头统筹"])


def _build(io: SeaTerminalIO) -> TerminalIOResponse:
    d = TerminalIOResponse.model_validate(io).model_dump()
    if io.ship:
        d["ship_name"] = io.ship.ship_name
    return TerminalIOResponse(**d)


@router.get("", response_model=PaginatedResponse[TerminalIOResponse], summary="获取码头统筹列表")
async def list_terminal_io(
    page: int = Query(default=1, ge=1), page_size: int = Query(default=20, ge=1, le=1000),
    operation_status: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    conds = []
    if operation_status:
        conds.append(SeaTerminalIO.operation_status == operation_status)
    cq = select(func.count()).select_from(SeaTerminalIO)
    if conds:
        cq = cq.where(*conds)
    total = (await db.execute(cq)).scalar()
    offset = (page - 1) * page_size
    q = select(SeaTerminalIO).options(selectinload(SeaTerminalIO.ship)).order_by(SeaTerminalIO.created_at.desc())
    if conds:
        q = q.where(*conds)
    q = q.offset(offset).limit(page_size)
    r = await db.execute(q)
    return PaginatedResponse(items=[_build(i) for i in r.scalars().all()], total=total, page=page, page_size=page_size)


@router.get("/{io_record_id}", response_model=TerminalIOResponse, summary="获取统筹详情")
async def get_terminal_io(io_record_id: str, db: AsyncSession = Depends(get_db)):
    q = select(SeaTerminalIO).options(selectinload(SeaTerminalIO.ship)).where(SeaTerminalIO.io_record_id == io_record_id)
    io = (await db.execute(q)).scalar_one_or_none()
    if not io:
        raise HTTPException(status_code=404, detail=f"统筹记录 {io_record_id} 不存在")
    return _build(io)


@router.post("", response_model=TerminalIOResponse, status_code=201, summary="创建统筹记录")
async def create_terminal_io(data: TerminalIOCreate, db: AsyncSession = Depends(get_db)):
    if await db.get(SeaTerminalIO, data.io_record_id):
        raise HTTPException(status_code=409, detail=f"记录 {data.io_record_id} 已存在")
    try:
        io = SeaTerminalIO(**data.model_dump())
        db.add(io)
        await db.flush(); await db.refresh(io)
        q = select(SeaTerminalIO).options(selectinload(SeaTerminalIO.ship)).where(SeaTerminalIO.io_record_id == io.io_record_id)
        return _build((await db.execute(q)).scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建失败: {str(e)}")


@router.put("/{io_record_id}/progress", response_model=TerminalIOResponse, summary="更新作业进度")
async def update_progress(io_record_id: str, data: TerminalIOProgressUpdate, db: AsyncSession = Depends(get_db)):
    io = await db.get(SeaTerminalIO, io_record_id)
    if not io:
        raise HTTPException(status_code=404, detail=f"统筹记录 {io_record_id} 不存在")
    try:
        io.operation_progress = data.operation_progress
        if data.operation_status:
            io.operation_status = data.operation_status
        await db.flush(); await db.refresh(io)
        q = select(SeaTerminalIO).options(selectinload(SeaTerminalIO.ship)).where(SeaTerminalIO.io_record_id == io_record_id)
        return _build((await db.execute(q)).scalar_one())
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"进度更新失败: {str(e)}")
