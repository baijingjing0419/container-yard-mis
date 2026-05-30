"""集装箱主数据表 Schema"""
from datetime import date, datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class ContainerMasterCreate(BaseModel):
    """新建集装箱主数据"""
    container_id: str = Field(..., max_length=20, description="箱号")
    container_type: str = Field(..., max_length=10, description="箱型: 20GP/40GP/40HQ/45HQ")
    tare_weight: Decimal | None = Field(None, description="皮重(kg)")
    owner_company: str | None = Field(None, max_length=100, description="所属公司")
    size_code: str | None = Field(None, max_length=10, description="尺寸代码")
    manufacture_date: date | None = Field(None, description="制造日期")


class ContainerMasterUpdate(BaseModel):
    """更新集装箱主数据（部分更新）"""
    container_type: str | None = Field(None, max_length=10)
    tare_weight: Decimal | None = None
    owner_company: str | None = Field(None, max_length=100)
    size_code: str | None = Field(None, max_length=10)
    manufacture_date: date | None = None


class ContainerMasterResponse(BaseModel):
    """集装箱主数据响应"""
    container_id: str
    container_type: str
    tare_weight: Decimal | None = None
    owner_company: str | None = None
    size_code: str | None = None
    manufacture_date: date | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
