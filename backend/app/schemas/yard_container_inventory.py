"""场内台账 Schema - 请求/响应数据验证"""
from datetime import datetime
from pydantic import BaseModel, Field


class InventoryCreate(BaseModel):
    """新增台账记录请求体（集装箱入场落箱时触发）"""
    container_id: str = Field(..., max_length=20, description="箱号")
    container_type: str = Field(..., max_length=10, description="箱型")
    container_status: str = Field(default="in_yard", max_length=20, description="箱状态")
    current_slot_id: str | None = Field(None, max_length=20, description="当前堆场位置")
    entry_time: datetime | None = Field(None, description="入场时间")
    expected_exit_time: datetime | None = Field(None, description="预计出场时间")
    ship_id: str | None = Field(None, max_length=20, description="关联船名航次")
    voyage_no: str | None = Field(None, max_length=20, description="航次号")
    pickup_plan_id: str | None = Field(None, max_length=30, description="提箱计划")
    is_overdue: bool = Field(default=False, description="是否超期")
    overdue_days: int = Field(default=0, description="超期天数")
    alert_level: str = Field(default="normal", max_length=10, description="预警级别")
    source_type: str | None = Field(None, max_length=20, description="来源类型")
    source_record_id: str | None = Field(None, max_length=30, description="来源记录号")


class InventoryUpdate(BaseModel):
    """更新台账记录请求体"""
    container_type: str | None = Field(None, max_length=10, description="箱型")
    container_status: str | None = Field(None, max_length=20, description="箱状态")
    current_slot_id: str | None = Field(None, max_length=20, description="当前堆场位置")
    expected_exit_time: datetime | None = Field(None, description="预计出场时间")
    actual_exit_time: datetime | None = Field(None, description="实际出场时间")
    dwell_time_hours: int | None = Field(None, description="停留时长")
    ship_id: str | None = Field(None, max_length=20, description="关联船名航次")
    is_overdue: bool | None = Field(None, description="是否超期")
    overdue_days: int | None = Field(None, description="超期天数")
    alert_level: str | None = Field(None, max_length=10, description="预警级别")


class InventoryLocationUpdate(BaseModel):
    """专用位置变更请求体 — 用于调箱后更新台账位置"""
    current_slot_id: str = Field(..., max_length=20, description="新堆场位置")


class InventoryResponse(BaseModel):
    """场内台账响应体 - 含关联数据展开"""
    inventory_id: int
    container_id: str
    container_type: str
    container_status: str | None = None
    current_slot_id: str | None = None
    previous_slot_id: str | None = None
    position_history: str | None = None
    entry_time: datetime | None = None
    expected_exit_time: datetime | None = None
    actual_exit_time: datetime | None = None
    dwell_time_hours: int | None = None
    ship_id: str | None = None
    voyage_no: str | None = None
    pickup_plan_id: str | None = None
    is_overdue: bool | None = None
    overdue_days: int | None = None
    alert_level: str | None = None
    source_type: str | None = None
    source_record_id: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    # 关联展开
    ship_name: str | None = None
    slot_label: str | None = None
    container_info: str | None = None

    class Config:
        from_attributes = True
