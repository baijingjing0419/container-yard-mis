"""海侧入场集装箱信息表 ORM 模型 (D1)"""
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, func, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class SeaInboundContainer(Base):
    __tablename__ = "sea_inbound_containers"

    container_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("containers_master.container_id"), primary_key=True, comment="箱号"
    )
    container_status: Mapped[str] = mapped_column(String(20), default="intact", comment="箱状态")

    # 船名航次（外键关联 ships）
    ship_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("ships.ship_id"), nullable=False, index=True, comment="船名航次"
    )

    # 航次号
    voyage_no: Mapped[str] = mapped_column(String(20), nullable=False, comment="航次号")

    # 舱单信息
    manifest_info: Mapped[str | None] = mapped_column(String(100), comment="舱单信息")

    # 残损情况
    damage_status: Mapped[str] = mapped_column(String(50), default="完好", comment="残损情况")

    # 入场时间（场桥落箱完成时间）
    entry_time: Mapped[datetime | None] = mapped_column(DateTime, comment="入场时间")

    # 目标堆位（外键关联 yard_slots）
    target_slot_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), comment="目标堆位"
    )

    # 实际落箱位（外键关联 yard_slots）
    actual_slot_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), comment="实际落箱位"
    )

    # 作业关联信息
    operation_id: Mapped[str | None] = mapped_column(String(30), comment="关联作业记录号")
    plan_id: Mapped[str | None] = mapped_column(String(30), comment="关联计划号")

    # 设备追溯
    discharge_crane: Mapped[str | None] = mapped_column(String(20), comment="卸船岸桥编号")
    transfer_truck: Mapped[str | None] = mapped_column(String(20), comment="转运内集卡编号")
    yard_crane: Mapped[str | None] = mapped_column(String(20), comment="落箱场桥编号")

    # 作业状态：pending/transiting/landed/completed
    process_status: Mapped[str] = mapped_column(String(20), default="pending", comment="作业状态")

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
    container_master: Mapped["ContainerMaster"] = relationship(
        "ContainerMaster", lazy="selectin"
    )
    ship: Mapped["Ship"] = relationship("Ship", lazy="selectin")
    target_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot", foreign_keys=[target_slot_id], lazy="selectin"
    )
    actual_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot", foreign_keys=[actual_slot_id], lazy="selectin"
    )
