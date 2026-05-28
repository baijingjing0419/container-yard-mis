"""海侧作业计划表 ORM"""
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, Integer, DECIMAL, DateTime, ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class SeaOperationPlan(Base):
    __tablename__ = "sea_operation_plans"

    plan_id: Mapped[str] = mapped_column(String(30), primary_key=True, comment="计划编号")
    plan_type: Mapped[str] = mapped_column(String(20), nullable=False, comment="计划类型: discharge/load")
    voyage_no: Mapped[str] = mapped_column(String(20), nullable=False, comment="航次号")
    ship_id: Mapped[str] = mapped_column(String(20), ForeignKey("ships.ship_id"), nullable=False, comment="船舶编号")
    planned_berth_time: Mapped[datetime | None] = mapped_column(DateTime, comment="计划靠泊时间")
    planned_depart_time: Mapped[datetime | None] = mapped_column(DateTime, comment="计划离泊时间")
    actual_berth_time: Mapped[datetime | None] = mapped_column(DateTime, comment="实际靠泊时间")
    actual_depart_time: Mapped[datetime | None] = mapped_column(DateTime, comment="实际离泊时间")
    planned_inbound: Mapped[int] = mapped_column(Integer, default=0, comment="计划入场箱量")
    planned_outbound: Mapped[int] = mapped_column(Integer, default=0, comment="计划出场箱量")
    actual_inbound: Mapped[int] = mapped_column(Integer, default=0, comment="实际入场箱量")
    actual_outbound: Mapped[int] = mapped_column(Integer, default=0, comment="实际出场箱量")
    assigned_quay_cranes: Mapped[str | None] = mapped_column(String(100), comment="分配岸桥")
    assigned_yard_cranes: Mapped[str | None] = mapped_column(String(100), comment="分配场桥")
    assigned_trucks: Mapped[str | None] = mapped_column(String(100), comment="分配内集卡")
    plan_status: Mapped[str] = mapped_column(String(20), default="draft", comment="计划状态")
    completion_rate: Mapped[Decimal | None] = mapped_column(DECIMAL(5, 2), default=0, comment="完成率")
    sea_io_record_id: Mapped[str | None] = mapped_column(String(30), comment="关联码头出入场记录")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    ship: Mapped["Ship"] = relationship("Ship", lazy="selectin")
