"""场内调度指令信息表 ORM 模型 (D9)"""
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, DECIMAL, DateTime, ForeignKey, func, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class DispatchOrder(Base):
    __tablename__ = "dispatch_orders"

    # 指令号（主键），如 DI-20260528-201
    order_id: Mapped[str] = mapped_column(String(30), primary_key=True, comment="指令号")

    # 指令类型：sea_inbound/sea_outbound/land_inbound/land_outbound/yard_shift
    order_type: Mapped[str] = mapped_column(String(20), nullable=False, index=True, comment="指令类型")

    # 时间信息
    issue_time: Mapped[datetime] = mapped_column(DateTime, nullable=False, comment="下达时间")
    planned_finish_time: Mapped[datetime | None] = mapped_column(DateTime, comment="计划完成时间")
    actual_finish_time: Mapped[datetime | None] = mapped_column(DateTime, comment="实际完成时间")

    # 部门信息
    issue_dept: Mapped[str | None] = mapped_column(String(50), comment="下达部门")
    execute_dept: Mapped[str | None] = mapped_column(String(50), comment="执行部门")

    # 集装箱信息
    container_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("sea_inbound_containers.container_id"), index=True, comment="箱号"
    )
    container_type: Mapped[str | None] = mapped_column(String(10), comment="箱型")

    # 位置信息
    original_position: Mapped[str | None] = mapped_column(String(20), comment="原位置")
    target_position: Mapped[str | None] = mapped_column(String(20), comment="目标位置")

    # 作业要求
    operation_requirement: Mapped[str | None] = mapped_column(Text, comment="作业要求")

    # 优先级：urgent/high/normal/low
    priority_level: Mapped[str] = mapped_column(String(10), default="normal", comment="优先级")

    # 执行状态：issued/acknowledged/in_progress/completed/cancelled
    execution_status: Mapped[str] = mapped_column(String(20), default="issued", index=True, comment="执行状态")

    # 执行进度百分比
    execution_progress: Mapped[Decimal | None] = mapped_column(DECIMAL(5, 2), default=0, comment="执行进度")

    # 关联信息
    related_plan_id: Mapped[str | None] = mapped_column(String(30), comment="关联作业计划号")
    related_ship_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("ships.ship_id"), comment="关联船舶"
    )

    # 闭环管理
    completion_remark: Mapped[str | None] = mapped_column(Text, comment="完成备注")
    exception_reason: Mapped[str | None] = mapped_column(Text, comment="异常原因")

    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), comment="创建时间"
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
        comment="更新时间",
    )

    # 多对一关联
    container: Mapped["SeaInboundContainer | None"] = relationship(
        "SeaInboundContainer", lazy="selectin"
    )
    related_ship: Mapped["Ship | None"] = relationship("Ship", lazy="selectin")
