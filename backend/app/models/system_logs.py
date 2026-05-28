"""系统操作日志表 ORM"""
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, func, Text
from sqlalchemy.orm import Mapped, mapped_column
from app.core.database import Base


class SystemLog(Base):
    __tablename__ = "system_logs"

    log_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="日志ID")
    log_type: Mapped[str | None] = mapped_column(String(20), comment="日志类型: operation/login/error/warning")
    user_id: Mapped[str | None] = mapped_column(String(20), comment="操作用户")
    operation: Mapped[str | None] = mapped_column(String(100), comment="操作描述")
    table_name: Mapped[str | None] = mapped_column(String(50), comment="操作表名")
    record_id: Mapped[str | None] = mapped_column(String(30), comment="操作记录ID")
    old_value: Mapped[str | None] = mapped_column(Text, comment="修改前值")
    new_value: Mapped[str | None] = mapped_column(Text, comment="修改后值")
    ip_address: Mapped[str | None] = mapped_column(String(50), comment="IP地址")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
