"""堆场箱位 Schema - 请求/响应数据验证"""
from decimal import Decimal
from pydantic import BaseModel, Field


class SlotCreate(BaseModel):
    """新增箱位请求体"""
    slot_id: str = Field(..., max_length=20, description="箱位编号，如 A-12-04")
    zone_id: str = Field(..., max_length=10, description="所属区域编号")
    row_num: int = Field(..., description="排号")
    col_num: int = Field(..., description="列号")
    tier_num: int = Field(default=1, description="层号")
    slot_status: str = Field(default="empty", max_length=20, description="状态: empty/occupied/reserved/maintenance")
    current_container_id: str | None = Field(None, max_length=20, description="当前存放箱号")
    max_weight: Decimal | None = Field(None, description="最大承重(吨)")
    slot_size: str | None = Field(None, max_length=10, description="适用箱型")


class SlotResponse(BaseModel):
    """箱位信息响应体"""
    slot_id: str
    zone_id: str
    row_num: int
    col_num: int
    tier_num: int
    slot_status: str
    current_container_id: str | None = None
    max_weight: Decimal | None = None
    slot_size: str | None = None

    class Config:
        from_attributes = True
