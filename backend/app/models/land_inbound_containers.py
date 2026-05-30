"""陆侧入场集装箱信息表 ORM 模型 (D4)"""
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, func, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class LandInboundContainer(Base):
    __tablename__ = "land_inbound_containers"
    __table_args__ = (
        Index("idx_land_inbound_gate", "truck_plate", "entry_time"),
    )

    container_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("containers_master.container_id"), primary_key=True, comment="箱号"
    )
    container_status: Mapped[str] = mapped_column(String(20), default="intact", comment="箱状态")

    truck_plate: Mapped[str | None] = mapped_column(String(20), comment="车牌号码")
    driver_name: Mapped[str | None] = mapped_column(String(50), comment="司机姓名")
    driver_phone: Mapped[str | None] = mapped_column(String(20), comment="司机电话")

    document_no: Mapped[str | None] = mapped_column(String(50), comment="单证号")
    document_type: Mapped[str | None] = mapped_column(String(20), comment="单证类型")

    ship_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("ships.ship_id"), comment="关联船名航次")
    voyage_no: Mapped[str | None] = mapped_column(String(20), comment="航次号")

    entry_time: Mapped[datetime | None] = mapped_column(DateTime, comment="入场时间")
    gate_pass_time: Mapped[datetime | None] = mapped_column(DateTime, comment="闸口通过时间")
    target_slot_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("yard_slots.slot_id"), comment="目标堆位")
    actual_slot_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("yard_slots.slot_id"), comment="实际落箱位")

    damage_check: Mapped[str] = mapped_column(String(20), default="完好", comment="残损确认")
    damage_photo_url: Mapped[str | None] = mapped_column(String(255), comment="残损照片URL")

    operation_id: Mapped[str | None] = mapped_column(String(30), comment="关联作业记录号")
    plan_id: Mapped[str | None] = mapped_column(String(30), comment="关联计划号")

    process_status: Mapped[str] = mapped_column(String(20), default="pending", comment="作业状态")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    ship: Mapped["Ship | None"] = relationship("Ship", lazy="selectin")
    target_slot: Mapped["YardSlot | None"] = relationship("YardSlot", foreign_keys=[target_slot_id], lazy="selectin")
    actual_slot: Mapped["YardSlot | None"] = relationship("YardSlot", foreign_keys=[actual_slot_id], lazy="selectin")
