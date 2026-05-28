"""船舶信息表 ORM 模型"""
from datetime import datetime
from sqlalchemy import String, Integer, DECIMAL, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class Ship(Base):
    __tablename__ = "ships"

    # 船舶编号（主键），如 COSCO-2405, MAERSK-8821
    ship_id: Mapped[str] = mapped_column(String(20), primary_key=True, comment="船舶编号")

    # 船舶名称
    ship_name: Mapped[str] = mapped_column(String(100), nullable=False, comment="船舶名称")

    # 船舶类型（集装箱船/散货船等）
    ship_type: Mapped[str | None] = mapped_column(String(20), comment="船舶类型")

    # 所属船公司
    ship_company: Mapped[str | None] = mapped_column(String(100), comment="船公司")

    # 船长（米）
    ship_length: Mapped[float | None] = mapped_column(DECIMAL(8, 2), comment="船长(米)")

    # 载箱量（TEU）
    ship_capacity: Mapped[int | None] = mapped_column(Integer, comment="载箱量(TEU)")

    # 状态：active=运营中, retired=已退役
    status: Mapped[str] = mapped_column(String(20), default="active", comment="状态")

    # 记录创建时间
    created_at: Mapped[datetime] = mapped_column(
        DateTime, server_default=func.current_timestamp(), comment="创建时间"
    )

    # 记录最后更新时间
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        server_default=func.current_timestamp(),
        onupdate=func.current_timestamp(),
        comment="更新时间",
    )
