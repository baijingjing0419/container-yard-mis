"""认证 API — 简易登录（已集成 JWT）"""
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field
from jose import jwt

from app.core.config import settings
from app.core.database import get_db
from app.core.security import verify_password
from app.models.users import User

router = APIRouter(prefix="/auth", tags=["认证"])


class LoginRequest(BaseModel):
    user_id: str = Field(..., max_length=20, description="工号")
    password: str = Field(default="", max_length=128, description="密码")


class LoginResponse(BaseModel):
    user_id: str
    username: str
    real_name: str | None
    role: str
    department: str | None
    phone: str | None
    email: str | None
    access_token: str
    token_type: str = "bearer"

    class Config:
        from_attributes = True


@router.post("/login", response_model=LoginResponse, summary="用户登录")
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """根据工号登录，签发 JWT access token（管理员暂免密）"""
    result = await db.execute(
        select(User).where(User.user_id == data.user_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="工号不存在")
    if user.status != "active":
        raise HTTPException(status_code=403, detail="账号已被禁用")
    if user.role != "admin":
        if not data.password:
            raise HTTPException(status_code=401, detail="请输入密码")
        if not verify_password(data.password, user.password_hash):
            raise HTTPException(status_code=401, detail="密码错误")

    # 生成 JWT（payload: sub=user_id, exp=过期时间）
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    token = jwt.encode(
        {"sub": user.user_id, "exp": expire, "iat": datetime.now(timezone.utc)},
        settings.SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )

    return LoginResponse(
        user_id=user.user_id,
        username=user.username,
        real_name=user.real_name,
        role=user.role,
        department=user.department,
        phone=user.phone,
        email=user.email,
        access_token=token,
        token_type="bearer",
    )
