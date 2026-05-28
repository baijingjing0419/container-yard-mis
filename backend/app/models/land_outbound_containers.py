"""陆侧出场集装箱信息表 ORM 模型 (D5)"""
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class LandOutboundContainer(Base):
    __tablename__ = "land_outbound_containers"

    container_id: Mapped[str] = mapped_column(String(20), primary_key=True, comment="箱号")
    container_type: Mapped[str] = mapped_column(String(10), nullable=False, comment="箱型")
    container_status: Mapped[str] = mapped_column(String(20), default="ready", comment="箱状态")

    truck_plate: Mapped[str | None] = mapped_column(String(20), comment="车牌号码")
    driver_name: Mapped[str | None] = mapped_column(String(50), comment="司机姓名")
    driver_phone: Mapped[str | None] = mapped_column(String(20), comment="司机电话")

    pickup_document_no: Mapped[str | None] = mapped_column(String(50), comment="提箱单证号")
    document_type: Mapped[str | None] = mapped_column(String(20), comment="单证类型")

    ship_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("ships.ship_id"), comment="关联船名航次")
    voyage_no: Mapped[str | None] = mapped_column(String(20), comment="航次号")

    original_slot_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("yard_slots.slot_id"), comment="原堆位")

    exit_time: Mapped[datetime | None] = mapped_column(DateTime, comment="出场时间")
    gate_pass_time: Mapped[datetime | None] = mapped_column(DateTime, comment="闸口通过时间")
    release_confirm_time: Mapped[datetime | None] = mapped_column(DateTime, comment="放行确认时间")

    operation_id: Mapped[str | None] = mapped_column(String(30), comment="关联作业记录号")
    plan_id: Mapped[str | None] = mapped_column(String(30), comment="关联计划号")

    process_status: Mapped[str] = mapped_column(String(20), default="planned", comment="作业状态")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    ship: Mapped["Ship | None"] = relationship("Ship", lazy="selectin")
    original_slot: Mapped["YardSlot | None"] = relationship("YardSlot", foreign_keys=[original_slot_id], lazy="selectin")
