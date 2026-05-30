"""海侧进箱 Schema - 请求/响应数据验证"""
from datetime import datetime
from pydantic import BaseModel, Field


class SeaInboundCreate(BaseModel):
    """新增海侧进箱记录请求体（container_type 已迁移至 containers_master）"""
    container_id: str = Field(..., max_length=20, description="箱号")
    container_type: str = Field(..., max_length=10, description="箱型（用于主数据自动创建）")
    container_status: str = Field(default="intact", max_length=20, description="箱状态")
    ship_id: str = Field(..., max_length=20, description="船名航次")
    voyage_no: str = Field(..., max_length=20, description="航次号")
    manifest_info: str | None = Field(None, max_length=100, description="舱单信息")
    damage_status: str = Field(default="完好", max_length=50, description="残损情况")
    entry_time: datetime | None = Field(None, description="入场时间")
    target_slot_id: str | None = Field(None, max_length=20, description="目标堆位")
    actual_slot_id: str | None = Field(None, max_length=20, description="实际落箱位")
    operation_id: str | None = Field(None, max_length=30, description="关联作业记录号")
    plan_id: str | None = Field(None, max_length=30, description="关联计划号")
    discharge_crane: str | None = Field(None, max_length=20, description="卸船岸桥")
    transfer_truck: str | None = Field(None, max_length=20, description="转运内集卡")
    yard_crane: str | None = Field(None, max_length=20, description="落箱场桥")
    process_status: str = Field(default="pending", max_length=20, description="作业状态")


class SeaInboundUpdate(BaseModel):
    """更新海侧进箱记录请求体"""
    container_type: str | None = Field(None, max_length=10, description="箱型")
    container_status: str | None = Field(None, max_length=20, description="箱状态")
    ship_id: str | None = Field(None, max_length=20, description="船名航次")
    voyage_no: str | None = Field(None, max_length=20, description="航次号")
    manifest_info: str | None = Field(None, max_length=100, description="舱单信息")
    damage_status: str | None = Field(None, max_length=50, description="残损情况")
    entry_time: datetime | None = Field(None, description="入场时间")
    target_slot_id: str | None = Field(None, max_length=20, description="目标堆位")
    actual_slot_id: str | None = Field(None, max_length=20, description="实际落箱位")
    operation_id: str | None = Field(None, max_length=30, description="关联作业记录号")
    plan_id: str | None = Field(None, max_length=30, description="关联计划号")
    discharge_crane: str | None = Field(None, max_length=20, description="卸船岸桥")
    transfer_truck: str | None = Field(None, max_length=20, description="转运内集卡")
    yard_crane: str | None = Field(None, max_length=20, description="落箱场桥")
    process_status: str | None = Field(None, max_length=20, description="作业状态")


class SeaInboundStatusUpdate(BaseModel):
    """专用状态更新请求体"""
    process_status: str = Field(..., max_length=20, description="新状态: pending/transiting/landed/completed")


class SeaInboundResponse(BaseModel):
    """海侧进箱记录响应体 - 含关联数据展开"""
    container_id: str
    container_type: str | None = None
    container_status: str | None = None
    ship_id: str
    voyage_no: str
    manifest_info: str | None = None
    damage_status: str | None = None
    entry_time: datetime | None = None
    target_slot_id: str | None = None
    actual_slot_id: str | None = None
    operation_id: str | None = None
    plan_id: str | None = None
    discharge_crane: str | None = None
    transfer_truck: str | None = None
    yard_crane: str | None = None
    process_status: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    # 关联展开字段
    ship_name: str | None = None
    target_slot_label: str | None = None
    actual_slot_label: str | None = None

    class Config:
        from_attributes = True
