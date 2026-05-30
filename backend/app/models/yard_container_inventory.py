"""场内集装箱信息表 ORM 模型 (D7) — 堆场管理的数据心脏"""
from datetime import datetime
from sqlalchemy import String, Integer, Boolean, DateTime, ForeignKey, func, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class YardContainerInventory(Base):
    __tablename__ = "yard_container_inventory"
    __table_args__ = (
        Index("idx_inventory_overdue", "is_overdue", "alert_level"),
    )

    inventory_id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True, comment="台账记录ID"
    )
    container_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("containers_master.container_id"), nullable=False, index=True, comment="箱号"
    )
    container_status: Mapped[str] = mapped_column(
        String(20), default="in_yard", index=True, comment="箱状态: in_yard/in_transit/outbound/damaged"
    )
    current_slot_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), comment="当前堆场位置"
    )
    previous_slot_id: Mapped[str | None] = mapped_column(String(20), comment="上一位置")

    entry_time: Mapped[datetime | None] = mapped_column(DateTime, comment="入场时间")
    expected_exit_time: Mapped[datetime | None] = mapped_column(DateTime, comment="预计出场时间")
    actual_exit_time: Mapped[datetime | None] = mapped_column(DateTime, comment="实际出场时间")
    dwell_time_hours: Mapped[int] = mapped_column(Integer, default=0, comment="停留时长(小时)")

    ship_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("ships.ship_id"), comment="关联船名航次")
    voyage_no: Mapped[str | None] = mapped_column(String(20), comment="航次号")
    pickup_plan_id: Mapped[str | None] = mapped_column(String(30), comment="提箱计划")

    is_overdue: Mapped[bool] = mapped_column(Boolean, default=False, index=True, comment="是否超期滞留")
    overdue_days: Mapped[int] = mapped_column(Integer, default=0, comment="超期天数")
    alert_level: Mapped[str] = mapped_column(String(10), default="normal", index=True, comment="预警级别")

    source_type: Mapped[str | None] = mapped_column(String(20), comment="来源类型: sea_inbound/land_inbound")
    source_record_id: Mapped[str | None] = mapped_column(String(30), comment="来源记录号")

    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), comment="创建时间"
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp(), comment="更新时间"
    )

    container: Mapped["ContainerMaster"] = relationship("ContainerMaster", lazy="selectin")
    current_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot", foreign_keys=[current_slot_id], lazy="selectin"
    )
    ship: Mapped["Ship | None"] = relationship("Ship", lazy="selectin")
