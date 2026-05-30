"""调度指令 Schema - 请求/响应数据验证"""
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class DispatchCreate(BaseModel):
    """下发新调度指令请求体"""
    order_id: str = Field(..., max_length=30, description="指令号，如 DI-20260528-201")
    order_type: str = Field(..., max_length=20, description="指令类型: sea_inbound/sea_outbound/land_inbound/land_outbound/yard_shift")
    issue_time: datetime = Field(..., description="下达时间")
    planned_finish_time: datetime | None = Field(None, description="计划完成时间")
    issue_dept: str | None = Field(None, max_length=50, description="下达部门")
    execute_dept: str | None = Field(None, max_length=50, description="执行部门")
    container_id: str | None = Field(None, max_length=20, description="箱号")
    original_position: str | None = Field(None, max_length=20, description="原位置")
    target_position: str = Field(..., max_length=20, description="目标位置")
    operation_requirement: str | None = Field(None, description="作业要求")
    priority_level: str = Field(default="normal", max_length=10, description="优先级: urgent/high/normal/low")
    related_plan_id: str | None = Field(None, max_length=30, description="关联计划号")
    related_ship_id: str | None = Field(None, max_length=20, description="关联船舶")


class DispatchUpdate(BaseModel):
    """更新调度指令请求体"""
    order_type: str | None = Field(None, max_length=20, description="指令类型")
    planned_finish_time: datetime | None = Field(None, description="计划完成时间")
    actual_finish_time: datetime | None = Field(None, description="实际完成时间")
    issue_dept: str | None = Field(None, max_length=50, description="下达部门")
    execute_dept: str | None = Field(None, max_length=50, description="执行部门")
    container_id: str | None = Field(None, max_length=20, description="箱号")
    original_position: str | None = Field(None, max_length=20, description="原位置")
    target_position: str | None = Field(None, max_length=20, description="目标位置")
    operation_requirement: str | None = Field(None, description="作业要求")
    priority_level: str | None = Field(None, max_length=10, description="优先级")
    execution_progress: Decimal | None = Field(None, description="执行进度")
    related_plan_id: str | None = Field(None, max_length=30, description="关联计划号")
    related_ship_id: str | None = Field(None, max_length=20, description="关联船舶")
    completion_remark: str | None = Field(None, description="完成备注")
    exception_reason: str | None = Field(None, description="异常原因")


class DispatchStatusUpdate(BaseModel):
    """专用状态更新请求体"""
    execution_status: str = Field(..., max_length=20, description="新状态: issued/acknowledged/in_progress/completed/cancelled")


class DispatchResponse(BaseModel):
    """调度指令响应体 - 含关联数据展开"""
    id: int | None = None
    order_id: str
    order_type: str
    issue_time: datetime
    planned_finish_time: datetime | None = None
    actual_finish_time: datetime | None = None
    issue_dept: str | None = None
    execute_dept: str | None = None
    container_id: str | None = None
    container_type: str | None = None
    original_position: str | None = None
    target_position: str | None = None
    operation_requirement: str | None = None
    priority_level: str | None = None
    execution_status: str | None = None
    execution_progress: Decimal | None = None
    related_plan_id: str | None = None
    related_ship_id: str | None = None
    completion_remark: str | None = None
    exception_reason: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    # 关联展开字段
    ship_name: str | None = None
    container_info: str | None = None

    class Config:
        from_attributes = True
