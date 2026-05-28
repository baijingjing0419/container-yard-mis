"""船舶信息 Schema - 请求/响应数据验证"""
from datetime import datetime
from pydantic import BaseModel, Field


class ShipCreate(BaseModel):
    """新增船舶请求体"""
    ship_id: str = Field(..., max_length=20, description="船舶编号，如 COSCO-2405")
    ship_name: str = Field(..., max_length=100, description="船舶名称")
    ship_type: str | None = Field(None, max_length=20, description="船舶类型")
    ship_company: str | None = Field(None, max_length=100, description="船公司")
    ship_length: float | None = Field(None, description="船长(米)")
    ship_capacity: int | None = Field(None, description="载箱量(TEU)")
    status: str = Field(default="active", max_length=20, description="状态")


class ShipUpdate(BaseModel):
    """更新船舶请求体 - 所有字段可选，只传需要更新的字段"""
    ship_name: str | None = Field(None, max_length=100, description="船舶名称")
    ship_type: str | None = Field(None, max_length=20, description="船舶类型")
    ship_company: str | None = Field(None, max_length=100, description="船公司")
    ship_length: float | None = Field(None, description="船长(米)")
    ship_capacity: int | None = Field(None, description="载箱量(TEU)")
    status: str | None = Field(None, max_length=20, description="状态")


class ShipResponse(BaseModel):
    """船舶信息响应体"""
    ship_id: str
    ship_name: str
    ship_type: str | None = None
    ship_company: str | None = None
    ship_length: float | None = None
    ship_capacity: int | None = None
    status: str
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True  # 支持从 ORM 对象直接转换
