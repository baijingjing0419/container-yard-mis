"""堆场作业记录 Schema - 请求/响应数据验证"""
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class OperationCreate(BaseModel):
    """新增作业记录请求体"""
    record_id: str = Field(..., max_length=30, description="作业记录号")
    operation_type: str = Field(..., max_length=20, description="作业类型: shift/land/pick/flip/inspect")
    container_id: str = Field(..., max_length=20, description="箱号")
    container_type: str | None = Field(None, max_length=10, description="箱型")
    original_slot_id: str | None = Field(None, max_length=20, description="原堆位")
    target_slot_id: str | None = Field(None, max_length=20, description="目标堆位")
    equipment_id: str | None = Field(None, max_length=20, description="作业机械编号")
    equipment_type: str | None = Field(None, max_length=20, description="机械类型")
    operator_name: str | None = Field(None, max_length=50, description="作业人员姓名")
    operator_id: str | None = Field(None, max_length=20, description="作业人员工号")
    start_time: datetime | None = Field(None, description="开始时间")
    dispatch_order_id: str | None = Field(None, max_length=30, description="关联调度指令号")
    source_operation: str | None = Field(None, max_length=20, description="指令来源")
    operation_status: str = Field(default="pending", max_length=20, description="作业状态")
    completion_remark: str | None = Field(None, description="完成备注")
    operation_cost: Decimal | None = Field(None, description="作业成本(元)")


class OperationStatusUpdate(BaseModel):
    """专用状态更新请求体"""
    operation_status: str = Field(..., max_length=20, description="新状态: pending/in_progress/completed/cancelled")


class OperationResponse(BaseModel):
    """作业记录响应体 - 含关联数据展开"""
    record_id: str
    operation_type: str
    container_id: str
    container_type: str | None = None
    original_slot_id: str | None = None
    target_slot_id: str | None = None
    equipment_id: str | None = None
    equipment_type: str | None = None
    operator_name: str | None = None
    operator_id: str | None = None
    start_time: datetime | None = None
    end_time: datetime | None = None
    duration_minutes: int | None = None
    dispatch_order_id: str | None = None
    source_operation: str | None = None
    operation_status: str | None = None
    completion_remark: str | None = None
    operation_cost: Decimal | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    # 关联展开
    original_slot_label: str | None = None
    target_slot_label: str | None = None
    container_info: str | None = None

    class Config:
        from_attributes = True
