"""异常告警表 ORM"""
from datetime import datetime
from sqlalchemy import String, Integer, Boolean, DateTime, func, Text
from sqlalchemy.orm import Mapped, mapped_column
from app.core.database import Base


class Alert(Base):
    __tablename__ = "alerts"

    alert_id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True, comment="告警ID")
    alert_type: Mapped[str | None] = mapped_column(String(30), comment="告警类型: overdue/congestion/equipment/schedule")
    alert_level: Mapped[str | None] = mapped_column(String(10), comment="告警级别: critical/warning/info")
    alert_title: Mapped[str | None] = mapped_column(String(200), comment="告警标题")
    alert_content: Mapped[str | None] = mapped_column(Text, comment="告警内容")
    related_record_type: Mapped[str | None] = mapped_column(String(30), comment="关联记录类型")
    related_record_id: Mapped[str | None] = mapped_column(String(30), comment="关联记录ID")
    is_resolved: Mapped[bool] = mapped_column(Boolean, default=False, index=True, comment="是否已处理")
    resolved_by: Mapped[str | None] = mapped_column(String(20), comment="处理人")
    resolved_time: Mapped[datetime | None] = mapped_column(DateTime, comment="处理时间")
    resolution_remark: Mapped[str | None] = mapped_column(Text, comment="处理备注")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
