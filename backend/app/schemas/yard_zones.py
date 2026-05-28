"""堆场区域 Schema - 请求/响应数据验证"""
from datetime import datetime
from pydantic import BaseModel, Field


class ZoneCreate(BaseModel):
    """新增区域请求体"""
    zone_id: str = Field(..., max_length=10, description="区域编号，如 A/B/C")
    zone_name: str = Field(..., max_length=50, description="区域名称")
    zone_type: str = Field(..., max_length=20, description="区域类型: import/export/transit")
    total_slots: int = Field(..., description="总箱位数")
    occupied_slots: int = Field(default=0, description="已占用箱位数")
    max_tier: int = Field(default=5, description="最大堆叠层数")
    status: str = Field(default="active", max_length=20, description="状态")


class ZoneUpdate(BaseModel):
    """更新区域请求体"""
    zone_name: str | None = Field(None, max_length=50, description="区域名称")
    zone_type: str | None = Field(None, max_length=20, description="区域类型")
    total_slots: int | None = Field(None, description="总箱位数")
    occupied_slots: int | None = Field(None, description="已占用箱位数")
    max_tier: int | None = Field(None, description="最大堆叠层数")
    status: str | None = Field(None, max_length=20, description="状态")


class ZoneResponse(BaseModel):
    """区域信息响应体"""
    zone_id: str
    zone_name: str
    zone_type: str
    total_slots: int
    occupied_slots: int
    max_tier: int
    status: str
    created_at: datetime | None = None

    class Config:
        from_attributes = True


class ZoneWithUtilization(ZoneResponse):
    """带利用率信息的区域响应体"""
    utilization_rate: float = Field(default=0.0, description="利用率百分比")
    empty_slots: int = Field(default=0, description="空闲箱位数")
