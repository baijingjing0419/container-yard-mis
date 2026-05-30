"""箱位移动流水表 ORM 模型 — 分区表不支持 DB 级 FK，使用 primaryjoin"""
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column, relationship, foreign

from app.core.database import Base


class ContainerMoveLog(Base):
    __tablename__ = "container_move_logs"

    log_id: Mapped[int] = mapped_column(
        Integer, primary_key=True, autoincrement=True, comment="日志ID"
    )
    container_id: Mapped[str] = mapped_column(
        String(20), nullable=False, comment="箱号"
    )
    from_slot_id: Mapped[str | None] = mapped_column(
        String(20), comment="原位置"
    )
    to_slot_id: Mapped[str] = mapped_column(
        String(20), nullable=False, comment="新位置"
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

    container: Mapped["ContainerMaster"] = relationship(
        "ContainerMaster",
        primaryjoin="foreign(ContainerMoveLog.container_id) == ContainerMaster.container_id",
        lazy="selectin",
    )
    from_slot: Mapped["YardSlot | None"] = relationship(
        "YardSlot",
        primaryjoin="foreign(ContainerMoveLog.from_slot_id) == YardSlot.slot_id",
        lazy="selectin",
    )
    to_slot: Mapped["YardSlot"] = relationship(
        "YardSlot",
        primaryjoin="foreign(ContainerMoveLog.to_slot_id) == YardSlot.slot_id",
        lazy="selectin",
    )
