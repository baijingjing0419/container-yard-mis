"""集装箱主数据表 ORM 模型 — 只记录集装箱固有物理属性"""
from datetime import date, datetime
from decimal import Decimal
from sqlalchemy import String, DECIMAL, Date, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class ContainerMaster(Base):
    __tablename__ = "containers_master"

    container_id: Mapped[str] = mapped_column(
        String(20), primary_key=True, comment="箱号，如 MSKU7892345"
    )
    container_type: Mapped[str] = mapped_column(
        String(10), nullable=False, comment="箱型：20GP/40GP/40HQ/45HQ"
    )
    tare_weight: Mapped[Decimal | None] = mapped_column(
        DECIMAL(10, 2), comment="皮重(kg)"
    )
    owner_company: Mapped[str | None] = mapped_column(
        String(100), comment="所属船公司/箱公司"
    )
    size_code: Mapped[str | None] = mapped_column(
        String(10), comment="尺寸代码，如 22G1/42G1"
    )
    manufacture_date: Mapped[date | None] = mapped_column(
        Date, comment="制造日期"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), onupdate=func.current_timestamp()
    )
