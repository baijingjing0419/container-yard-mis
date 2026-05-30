"""认证 API — 简易登录（后续可集成 JWT/OAuth）"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.core.database import get_db
from app.models.users import User

router = APIRouter(prefix="/auth", tags=["认证"])


class LoginRequest(BaseModel):
    username: str = Field(..., max_length=50, description="用户名")


class LoginResponse(BaseModel):
    user_id: str
    username: str
    real_name: str | None
    role: str
    department: str | None
    phone: str | None
    email: str | None

    class Config:
        from_attributes = True


@router.post("/login", response_model=LoginResponse, summary="用户登录")
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """根据用户名登录（密码验证后续整合 Auth 模块时加入）"""
    result = await db.execute(
        select(User).where(User.username == data.username)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="用户名不存在")
    if user.status != "active":
        raise HTTPException(status_code=403, detail="账号已被禁用")
    return LoginResponse.model_validate(user)
