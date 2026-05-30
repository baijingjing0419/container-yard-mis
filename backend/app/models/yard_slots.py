"""堆场箱位明细表 ORM 模型"""
from decimal import Decimal
from sqlalchemy import String, Integer, DECIMAL, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class YardSlot(Base):
    __tablename__ = "yard_slots"

    # 箱位编号（主键），如 A-12-04
    slot_id: Mapped[str] = mapped_column(String(20), primary_key=True, comment="箱位编号")

    # 所属区域（外键关联 yard_zones）
    zone_id: Mapped[str] = mapped_column(
        String(10), ForeignKey("yard_zones.zone_id"), nullable=False, comment="所属区域"
    )

    # 排号
    row_num: Mapped[int] = mapped_column(Integer, nullable=False, comment="排号")

    # 列号
    col_num: Mapped[int] = mapped_column(Integer, nullable=False, comment="列号")

    # 层号
    tier_num: Mapped[int] = mapped_column(Integer, default=1, comment="层号")

    # 状态：empty=空闲, occupied=已占用, reserved=预留, maintenance=维护
    slot_status: Mapped[str] = mapped_column(String(20), default="empty", index=True, comment="状态")

    # 当前存放集装箱号
    current_container_id: Mapped[str | None] = mapped_column(String(20), comment="当前存放箱号")

    # 最大承重（吨）
    max_weight: Mapped[Decimal | None] = mapped_column(DECIMAL(10, 2), comment="最大承重(吨)")

    # 适用箱型：20GP/40GP/40HQ/all
    slot_size: Mapped[str | None] = mapped_column(String(10), comment="适用箱型")

    # 多对一关联：所属的堆场区域
    zone: Mapped["YardZone"] = relationship("YardZone", back_populates="slots", lazy="selectin")
