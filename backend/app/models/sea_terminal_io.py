"""海侧码头出、入场信息表 ORM (D3)"""
from datetime import datetime
from decimal import Decimal
from sqlalchemy import String, Integer, DECIMAL, DateTime, ForeignKey, func, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class SeaTerminalIO(Base):
    __tablename__ = "sea_terminal_io"

    io_record_id: Mapped[str] = mapped_column(String(30), primary_key=True, comment="出入场记录号")
    voyage_no: Mapped[str] = mapped_column(String(20), nullable=False, comment="航次号")
    ship_id: Mapped[str] = mapped_column(String(20), ForeignKey("ships.ship_id"), nullable=False, comment="船舶编号")
    berth_time: Mapped[datetime | None] = mapped_column(DateTime, comment="靠泊时间")
    departure_time: Mapped[datetime | None] = mapped_column(DateTime, comment="离泊时间")
    inbound_total: Mapped[int] = mapped_column(Integer, default=0, comment="入场箱总量")
    outbound_total: Mapped[int] = mapped_column(Integer, default=0, comment="出场箱总量")
    operation_sequence: Mapped[str | None] = mapped_column(Text, comment="装卸作业顺序")
    stowage_plan: Mapped[str | None] = mapped_column(Text, comment="舱位配载计划")
    operation_progress: Mapped[Decimal | None] = mapped_column(DECIMAL(5, 2), default=0, comment="作业进度")
    assigned_quay_cranes: Mapped[str | None] = mapped_column(String(100), comment="分配岸桥")
    assigned_yard_cranes: Mapped[str | None] = mapped_column(String(100), comment="分配场桥")
    assigned_trucks: Mapped[str | None] = mapped_column(String(100), comment="分配内集卡")
    operation_status: Mapped[str] = mapped_column(String(20), default="planned", comment="作业状态")
    created_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp())
    updated_at: Mapped[datetime] = mapped_column(DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    ship: Mapped["Ship"] = relationship("Ship", lazy="selectin")
