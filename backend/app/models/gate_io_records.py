"""陆侧闸口出、入场信息表 ORM 模型 (D6)"""
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, func, Text, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class GateIORecord(Base):
    __tablename__ = "gate_io_records"
    __table_args__ = (
        Index("idx_gate_io_time", "entry_time", "exit_time"),
    )

    record_id: Mapped[str] = mapped_column(String(30), primary_key=True, comment="通行记录号")
    gate_lane_no: Mapped[str | None] = mapped_column(String(10), comment="闸口通道号")
    io_type: Mapped[str] = mapped_column(String(10), nullable=False, index=True, comment="进出类型: inbound/outbound")

    truck_plate: Mapped[str] = mapped_column(String(20), nullable=False, index=True, comment="车牌号码")
    driver_name: Mapped[str | None] = mapped_column(String(50), comment="司机姓名")

    container_id: Mapped[str | None] = mapped_column(String(20), ForeignKey("containers_master.container_id"), comment="箱号")
    container_type: Mapped[str | None] = mapped_column(String(10), comment="箱型")

    container: Mapped["ContainerMaster | None"] = relationship("ContainerMaster", lazy="selectin")

    document_no: Mapped[str | None] = mapped_column(String(50), comment="单证号")
    document_verify_result: Mapped[str] = mapped_column(String(20), default="passed", comment="核验结果: passed/failed/pending")

    damage_check: Mapped[str] = mapped_column(String(20), default="完好", comment="残损确认")
    damage_remark: Mapped[str | None] = mapped_column(Text, comment="残损备注")

    entry_time: Mapped[datetime | None] = mapped_column(DateTime, comment="入场时间")
    exit_time: Mapped[datetime | None] = mapped_column(DateTime, comment="出场时间")
    pass_duration: Mapped[int | None] = mapped_column(Integer, comment="通行时长(分钟)")

    release_status: Mapped[str] = mapped_column(String(20), default="pending", comment="放行状态: pending/approved/rejected")
    release_operator: Mapped[str | None] = mapped_column(String(50), comment="放行操作人员")

    operation_id: Mapped[str | None] = mapped_column(String(30), comment="关联作业记录号")
    plan_id: Mapped[str | None] = mapped_column(String(30), comment="关联计划号")

    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())
