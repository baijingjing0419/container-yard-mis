"""认证 API — 登录 / 密码设置 / 首次登录 / 初始化管理员"""
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field
from jose import jwt

from app.core.config import settings
from app.core.database import get_db
from app.core.security import verify_password, hash_password
from app.models.users import User

router = APIRouter(prefix="/auth", tags=["认证"])


class LoginRequest(BaseModel):
    user_id: str = Field(..., max_length=20, description="工号")
    password: str = Field(default="", max_length=128, description="密码")


class LoginResponse(BaseModel):
    needs_password_setup: bool = False
    user_id: str = ""
    username: str = ""
    real_name: str | None = None
    role: str = ""
    department: str | None = None
    phone: str | None = None
    email: str | None = None
    access_token: str = ""
    token_type: str = "bearer"


class SetupPasswordRequest(BaseModel):
    employee_id: str = Field(..., max_length=20, description="工号")
    password: str = Field(..., min_length=1, max_length=128, description="新密码")


class SetupAdminRequest(BaseModel):
    user_id: str = Field(..., max_length=20, description="管理员工号")
    real_name: str = Field(..., max_length=50, description="姓名")
    password: str = Field(..., min_length=1, max_length=128, description="密码")


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
    """根据工号登录。密码为空且 password_hash 未设置 → 跳转首次密码设置"""
    result = await db.execute(select(User).where(User.user_id == data.user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="工号不存在")
    if user.status != "active":
        raise HTTPException(status_code=403, detail="账号已被禁用")

    # 密码未设置 → 引导首次登录设置密码
    if user.password_hash is None:
        return LoginResponse(
            needs_password_setup=True,
            user_id=user.user_id,
            real_name=user.real_name,
            role=user.role,
        )

    if not data.password:
        raise HTTPException(status_code=401, detail="请输入密码")
    if not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="密码错误")

    user.last_login = datetime.now()
    await db.flush()

    return _build_login_response(user, _issue_token(user))


@router.post("/setup-password", summary="首次登录设置密码")
async def setup_password(data: SetupPasswordRequest, db: AsyncSession = Depends(get_db)):
    """员工首次登录设置密码，设置成功后直接签发 JWT"""
    result = await db.execute(select(User).where(User.user_id == data.employee_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="工号不存在")
    if user.password_hash is not None:
        raise HTTPException(status_code=400, detail="密码已设置，请使用登录接口")
    if len(data.password) < 1:
        raise HTTPException(status_code=400, detail="密码不能为空")

    user.password_hash = hash_password(data.password)
    user.last_login = datetime.now()
    await db.flush()

    return _build_login_response(user, _issue_token(user))


@router.post("/setup-admin", summary="系统初始化：创建首位管理员")
async def setup_admin(data: SetupAdminRequest, db: AsyncSession = Depends(get_db)):
    """仅当系统中无管理员时可用，创建第一个管理员并签发 JWT"""
    admin_count = (await db.execute(
        select(func.count()).select_from(User).where(User.role == "admin")
    )).scalar() or 0
    if admin_count > 0:
        raise HTTPException(status_code=400, detail="管理员已存在，请使用正常流程创建用户")

    existing = await db.get(User, data.user_id)
    if existing:
        raise HTTPException(status_code=409, detail=f"工号 {data.user_id} 已存在")

    user = User(
        user_id=data.user_id,
        username=data.user_id,
        real_name=data.real_name,
        role="admin",
        department="信息中心",
        password_hash=hash_password(data.password),
        last_login=datetime.now(),
    )
    db.add(user)
    await db.flush()

    return _build_login_response(user, _issue_token(user))
