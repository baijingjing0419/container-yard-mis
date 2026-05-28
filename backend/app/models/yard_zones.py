"""堆场区域定义表 ORM 模型"""
from datetime import datetime
from sqlalchemy import String, Integer, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class YardZone(Base):
    __tablename__ = "yard_zones"

    # 区域编号（主键），如 A, B, C
    zone_id: Mapped[str] = mapped_column(String(10), primary_key=True, comment="区域编号")

    # 区域名称
    zone_name: Mapped[str] = mapped_column(String(50), nullable=False, comment="区域名称")

    # 区域类型：import=进口箱区, export=出口箱区, transit=中转箱区
    zone_type: Mapped[str] = mapped_column(String(20), nullable=False, comment="区域类型")

    # 总箱位数
    total_slots: Mapped[int] = mapped_column(Integer, nullable=False, comment="总箱位数")

    # 已占用箱位数
    occupied_slots: Mapped[int] = mapped_column(Integer, default=0, comment="已占用箱位数")

    # 最大堆叠层数
    max_tier: Mapped[int] = mapped_column(Integer, default=5, comment="最大堆叠层数")

    # 状态：active=使用中, inactive=停用
    status: Mapped[str] = mapped_column(String(20), default="active", comment="状态")

    # 记录创建时间
    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), comment="创建时间"
    )

    # 一对多关联：区域下的所有箱位
    slots: Mapped[list["YardSlot"]] = relationship(
        "YardSlot", back_populates="zone", lazy="selectin"
    )
