"""海侧出场集装箱信息表 ORM (D2)"""
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, func, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class SeaOutboundContainer(Base):
    __tablename__ = "sea_outbound_containers"

    container_id: Mapped[str] = mapped_column(String(20), primary_key=True, comment="箱号")
    container_type: Mapped[str] = mapped_column(String(10), nullable=False, comment="箱型")
    container_status: Mapped[str] = mapped_column(String(20), default="loaded", comment="箱状态")
    ship_id: Mapped[str] = mapped_column(String(20), ForeignKey("ships.ship_id"), nullable=False, comment="目标船名航次")
    voyage_no: Mapped[str] = mapped_column(String(20), nullable=False, comment="航次号")
    stowage_position: Mapped[str | None] = mapped_column(String(20), comment="配载舱位")
    exit_time: Mapped[datetime | None] = mapped_column(DateTime, comment="出场时间")
    original_slot_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("yard_slots.slot_id"), comment="原堆位")
    load_complete_time: Mapped[datetime | None] = mapped_column(DateTime, comment="装船完成时间")
    document_info: Mapped[str | None] = mapped_column(Text, comment="单证信息")
    customs_status: Mapped[str] = mapped_column(String(20), default="cleared", comment="海关放行状态")
    operation_id: Mapped[str | None] = mapped_column(String(30), comment="关联出场作业号")
    plan_id: Mapped[str | None] = mapped_column(String(30), comment="关联计划号")
    yard_crane: Mapped[str | None] = mapped_column(String(20), comment="提箱场桥")
    transfer_truck: Mapped[str | None] = mapped_column(String(20), comment="转运内集卡")
    load_crane: Mapped[str | None] = mapped_column(String(20), comment="装船岸桥")
    process_status: Mapped[str] = mapped_column(String(20), default="planned", comment="作业状态")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    ship: Mapped["Ship"] = relationship("Ship", lazy="selectin")
    original_slot: Mapped["YardSlot | None"] = relationship("YardSlot", foreign_keys=[original_slot_id], lazy="selectin")
