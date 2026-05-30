"""认证 API — 登录"""
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
    user_id: str = ""
    username: str = ""
    real_name: str | None = None
    role: str = ""
    department: str | None = None
    phone: str | None = None
    email: str | None = None
    access_token: str = ""
    token_type: str = "bearer"


def _issue_token(user: User) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return jwt.encode(
        {"sub": user.user_id, "exp": expire, "iat": datetime.now(timezone.utc)},
        settings.SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def _build_login_response(user: User, token: str = "") -> LoginResponse:
    return LoginResponse(
        user_id=user.user_id,
        username=user.username,
        real_name=user.real_name,
        role=user.role,
        department=user.department,
        phone=user.phone,
        email=user.email,
        access_token=token,
    )


@router.post("/login", summary="用户登录")
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """根据工号+密码登录"""
    result = await db.execute(select(User).where(User.user_id == data.user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="工号不存在")
    if user.status != "active":
        raise HTTPException(status_code=403, detail="账号已被禁用")

    if not data.password:
        raise HTTPException(status_code=401, detail="请输入密码")
    if not verify_password(data.password, user.password_hash or ""):
        raise HTTPException(status_code=401, detail="密码错误")

    user.last_login = datetime.now()
    await db.flush()

    return _build_login_response(user, _issue_token(user))
