"""用户管理 API"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import SQLAlchemyError
from app.core.database import get_db
from app.models.users import User
from app.schemas.users import UserCreate, UserUpdate, UserStatusUpdate, UserResponse
from app.schemas.common import PaginatedResponse

router = APIRouter(prefix="/users", tags=["用户管理"])


@router.get("", response_model=PaginatedResponse[UserResponse], summary="获取用户列表")
async def list_users(
    page: int = Query(default=1, ge=1), page_size: int = Query(default=20, ge=1, le=1000),
    role: str | None = Query(None), department: str | None = Query(None),
    db: AsyncSession = Depends(get_db),
):
    conds = []
    if role:
        conds.append(User.role == role)
    if department:
        conds.append(User.department == department)
    cq = select(func.count()).select_from(User)
    if conds:
        cq = cq.where(*conds)
    total = (await db.execute(cq)).scalar()
    offset = (page - 1) * page_size
    q = select(User).order_by(User.created_at.desc())
    if conds:
        q = q.where(*conds)
    q = q.offset(offset).limit(page_size)
    r = await db.execute(q)
    return PaginatedResponse(items=[UserResponse.model_validate(u) for u in r.scalars().all()], total=total, page=page, page_size=page_size)


@router.get("/{user_id}", response_model=UserResponse, summary="获取用户详情")
async def get_user(user_id: str, db: AsyncSession = Depends(get_db)):
    u = await db.get(User, user_id)
    if not u:
        raise HTTPException(status_code=404, detail=f"用户 {user_id} 不存在")
    return UserResponse.model_validate(u)


@router.post("", response_model=UserResponse, status_code=201, summary="创建用户")
async def create_user(data: UserCreate, db: AsyncSession = Depends(get_db)):
    if await db.get(User, data.user_id):
        raise HTTPException(status_code=409, detail=f"用户 {data.user_id} 已存在")
    try:
        u = User(**data.model_dump())
        db.add(u)
        await db.flush(); await db.refresh(u)
        return UserResponse.model_validate(u)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"创建失败: {str(e)}")


@router.put("/{user_id}/status", response_model=UserResponse, summary="更新用户状态")
async def update_status(user_id: str, data: UserStatusUpdate, db: AsyncSession = Depends(get_db)):
    u = await db.get(User, user_id)
    if not u:
        raise HTTPException(status_code=404, detail=f"用户 {user_id} 不存在")
    try:
        u.status = data.status
        await db.flush(); await db.refresh(u)
        return UserResponse.model_validate(u)
    except SQLAlchemyError as e:
        await db.rollback()
        raise HTTPException(status_code=500, detail=f"状态更新失败: {str(e)}")
