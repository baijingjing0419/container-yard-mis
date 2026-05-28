"""陆侧作业计划表 ORM"""
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, Integer, DECIMAL, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from app.core.database import Base


class LandOperationPlan(Base):
    __tablename__ = "land_operation_plans"

    plan_id: Mapped[str] = mapped_column(String(30), primary_key=True, comment="计划编号")
    plan_type: Mapped[str] = mapped_column(String(20), nullable=False, comment="计划类型")
    planned_start_time: Mapped[datetime | None] = mapped_column(DateTime, comment="计划开始时间")
    planned_end_time: Mapped[datetime | None] = mapped_column(DateTime, comment="计划结束时间")
    actual_start_time: Mapped[datetime | None] = mapped_column(DateTime, comment="实际开始时间")
    actual_end_time: Mapped[datetime | None] = mapped_column(DateTime, comment="实际结束时间")
    planned_container_count: Mapped[int] = mapped_column(Integer, default=0, comment="预计箱量")
    actual_container_count: Mapped[int] = mapped_column(Integer, default=0, comment="实际完成箱量")
    assigned_gate_lanes: Mapped[str | None] = mapped_column(String(50), comment="分配闸口通道")
    plan_status: Mapped[str] = mapped_column(String(20), default="draft", comment="计划状态")
    completion_rate: Mapped[Decimal | None] = mapped_column(DECIMAL(5, 2), default=0, comment="完成率")
    gate_io_record_id: Mapped[str | None] = mapped_column(String(30), comment="关联闸口出入场记录")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())
