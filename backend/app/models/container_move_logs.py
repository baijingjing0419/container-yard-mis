"""箱位移动流水表 ORM 模型 — 每一次位置变更均记录，支持完整轨迹追溯"""
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class ContainerMoveLog(Base):
    __tablename__ = "container_move_logs"

    log_id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True, comment="日志ID"
    )
    container_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("containers_master.container_id"), nullable=False, comment="箱号"
    )
    from_slot_id: Mapped[str | None] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), comment="原位置"
    )
    to_slot_id: Mapped[str] = mapped_column(
        String(20), ForeignKey("yard_slots.slot_id"), nullable=False, comment="新位置"
    )
    move_time: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.current_timestamp(), comment="移动时间"
    )
    operator_name: Mapped[str | None] = mapped_column(
        String(50), comment="操作人员"
    )
    operation_id: Mapped[str | None] = mapped_column(
        String(30), comment="关联作业记录号"
    )
    equipment_id: Mapped[str | None] = mapped_column(
        String(20), comment="作业机械编号"
    )
    remark: Mapped[str | None] = mapped_column(
        String(200), comment="备注"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp()
    )

    container: Mapped["ContainerMaster"] = relationship("ContainerMaster", lazy="selectin")
    from_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot", foreign_keys=[from_slot_id], lazy="selectin"
    )
    to_slot: Mapped["YardSlot"] = relationship(
        "YardSlot", foreign_keys=[to_slot_id], lazy="selectin"
    )
