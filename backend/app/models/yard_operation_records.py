"""堆场作业记录表 ORM 模型 (D8) — 每次物理操作的执行记录"""
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, Integer, DECIMAL, DateTime, ForeignKey, func, Text, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class YardOperationRecord(Base):
    __tablename__ = "yard_operation_records"
    __table_args__ = (
        Index("idx_yard_op_time", "start_time", "end_time"),
    )

    # 作业记录号（主键），如 YM-20260528-089
    record_id: Mapped[str] = mapped_column(String(30), primary_key=True, comment="作业记录号")

    # 作业类型：shift=翻箱, land=落箱, pick=提箱, flip=倒箱, inspect=查验
    operation_type: Mapped[str] = mapped_column(String(20), nullable=False, index=True, comment="作业类型")

    container_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("containers_master.container_id"), nullable=False, comment="箱号"
    )

    # 原堆位（外键关联箱位表）
    original_slot_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), comment="原堆位"
    )

    # 目标堆位（外键关联箱位表）
    target_slot_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), comment="目标堆位"
    )

    # 设备与人员
    equipment_id: Mapped[str | None] = mapped_column(String(20), comment="作业机械编号")
    equipment_type: Mapped[str | None] = mapped_column(String(20), comment="机械类型: QC/YC/RTG")
    operator_name: Mapped[str | None] = mapped_column(String(50), comment="作业人员姓名")
    operator_id: Mapped[str | None] = mapped_column(String(20), comment="作业人员工号")

    # 时间信息
    start_time: Mapped[datetime | None] = mapped_column(DateTime, comment="作业开始时间")
    end_time: Mapped[datetime | None] = mapped_column(DateTime, comment="作业结束时间")
    duration_minutes: Mapped[int | None] = mapped_column(Integer, comment="作业时长(分钟)")

    # 指令关联
    dispatch_order_id: Mapped[str | None] = mapped_column(String(30), comment="关联调度指令号")
    source_operation: Mapped[str | None] = mapped_column(String(20), comment="指令来源")

    # 状态与备注
    operation_status: Mapped[str] = mapped_column(String(20), default="pending", comment="作业状态")
    completion_remark: Mapped[str | None] = mapped_column(Text, comment="完成备注")

    # 成本核算
    operation_cost: Mapped[Decimal | None] = mapped_column(DECIMAL(10, 2), comment="作业成本(元)")

    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), comment="创建时间"
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp(), comment="更新时间"
    )

    # 多对一关联 — 双 FK 到同一表，必须用 foreign_keys 区分
    container: Mapped["ContainerMaster"] = relationship("ContainerMaster", lazy="selectin")
    original_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot", foreign_keys=[original_slot_id], lazy="selectin"
    )
    target_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot", foreign_keys=[target_slot_id], lazy="selectin"
    )
