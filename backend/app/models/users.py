"""用户与权限表 ORM"""
from datetime import datetime
from sqlalchemy import String, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    user_id: Mapped[str] = mapped_column(String(20), primary_key=True, comment="用户ID")
    username: Mapped[str] = mapped_column(String(50), nullable=False, comment="用户名")
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False, comment="密码哈希")
    real_name: Mapped[str | None] = mapped_column(String(50), comment="真实姓名")
    role: Mapped[str] = mapped_column(String(20), nullable=False, comment="角色: admin/dispatcher/operator/gate_clerk/supervisor")
    department: Mapped[str | None] = mapped_column(String(50), comment="所属部门")
    phone: Mapped[str | None] = mapped_column(String(20), comment="联系电话")
    email: Mapped[str | None] = mapped_column(String(100), comment="邮箱")
    status: Mapped[str] = mapped_column(String(20), default="active", comment="状态: active/inactive")
    last_login: Mapped[datetime | None] = mapped_column(DateTime, comment="最后登录时间")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())
