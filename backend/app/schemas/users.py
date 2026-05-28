"""用户 Schema - UserResponse 不含 password_hash"""
from datetime import datetime
from pydantic import BaseModel, Field


class UserCreate(BaseModel):
    user_id: str = Field(..., max_length=20)
    username: str = Field(..., max_length=50)
    password_hash: str = Field(..., max_length=255, description="密码哈希（后续整合Auth）")
    real_name: str | None = Field(None, max_length=50)
    role: str = Field(..., max_length=20, description="admin/dispatcher/operator/gate_clerk/supervisor")
    department: str | None = Field(None, max_length=50)
    phone: str | None = Field(None, max_length=20)
    email: str | None = Field(None, max_length=100)
    status: str = Field(default="active", max_length=20)


class UserUpdate(BaseModel):
    username: str | None = Field(None, max_length=50)
    real_name: str | None = Field(None, max_length=50)
    role: str | None = Field(None, max_length=20)
    department: str | None = Field(None, max_length=50)
    phone: str | None = Field(None, max_length=20)
    email: str | None = Field(None, max_length=100)


class UserStatusUpdate(BaseModel):
    status: str = Field(..., max_length=20, description="active/inactive")


class UserResponse(BaseModel):
    """用户响应体 - 已脱敏，不包含 password_hash"""
    user_id: str
    username: str
    real_name: str | None = None
    role: str
    department: str | None = None
    phone: str | None = None
    email: str | None = None
    status: str | None = None
    last_login: datetime | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
