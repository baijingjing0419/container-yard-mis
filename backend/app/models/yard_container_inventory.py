"""场内集装箱信息表 ORM 模型 (D7) — 堆场管理的数据心脏"""
from datetime import datetime
from sqlalchemy import String, Integer, Boolean, DateTime, ForeignKey, func, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class YardContainerInventory(Base):
    __tablename__ = "yard_container_inventory"

    # 台账记录ID（自增主键）
    inventory_id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True, comment="台账记录ID"
    )

    # 箱号（外键关联海侧进箱表）
    container_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("sea_inbound_containers.container_id"), nullable=False, index=True, comment="箱号"
    )

    # 箱型
    container_type: Mapped[str] = mapped_column(String(10), nullable=False, comment="箱型")

    # 箱状态：in_yard=在堆, in_transit=转运中, outbound=待出场, damaged=残损
    container_status: Mapped[str] = mapped_column(String(20), default="in_yard", index=True, comment="箱状态")

    # 当前位置（外键关联箱位表）
    current_slot_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), comment="当前堆场位置"
    )

    # 上一位置（用于追溯调箱历史）
    previous_slot_id: Mapped[str | None] = mapped_column(String(20), comment="上一位置")

    # 历史位置记录（JSON格式）
    position_history: Mapped[str | None] = mapped_column(Text, comment="历史位置记录(JSON)")

    # 时间信息
    entry_time: Mapped[datetime | None] = mapped_column(DateTime, comment="入场时间")
    expected_exit_time: Mapped[datetime | None] = mapped_column(DateTime, comment="预计出场时间")
    actual_exit_time: Mapped[datetime | None] = mapped_column(DateTime, comment="实际出场时间")
    dwell_time_hours: Mapped[int] = mapped_column(Integer, default=0, comment="停留时长(小时)")

    # 关联信息
    ship_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("ships.ship_id"), comment="关联船名航次")
    voyage_no: Mapped[str | None] = mapped_column(String(20), comment="航次号")
    pickup_plan_id: Mapped[str | None] = mapped_column(String(30), comment="提箱计划")

    # 预警标记
    is_overdue: Mapped[bool] = mapped_column(Boolean, default=False, index=True, comment="是否超期滞留")
    overdue_days: Mapped[int] = mapped_column(Integer, default=0, comment="超期天数")
    alert_level: Mapped[str] = mapped_column(String(10), default="normal", index=True, comment="预警级别: normal/warning/critical")

    # 来源追踪
    source_type: Mapped[str | None] = mapped_column(String(20), comment="来源类型: sea_inbound/land_inbound")
    source_record_id: Mapped[str | None] = mapped_column(String(30), comment="来源记录号")

    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), comment="创建时间"
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp(), comment="更新时间"
    )

    # 多对一关联
    container: Mapped["SeaInboundContainer"] = relationship("SeaInboundContainer", lazy="selectin")
    current_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot", foreign_keys=[current_slot_id], lazy="selectin"
    )
    ship: Mapped["Ship | None"] = relationship("Ship", lazy="selectin")
