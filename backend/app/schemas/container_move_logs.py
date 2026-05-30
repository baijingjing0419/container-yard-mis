"""箱位移动流水表 Schema"""
from datetime import datetime
from pydantic import BaseModel, Field


class MoveLogCreate(BaseModel):
    """新增移动流水记录"""
    container_id: str = Field(..., max_length=20, description="箱号")
    from_slot_id: str | None = Field(None, max_length=20, description="原位置")
    to_slot_id: str = Field(..., max_length=20, description="新位置")
    move_time: datetime | None = Field(None, description="移动时间（默认当前时间）")
    operator_name: str | None = Field(None, max_length=50, description="操作人员")
    operation_id: str | None = Field(None, max_length=30, description="关联作业记录号")
    equipment_id: str | None = Field(None, max_length=20, description="作业机械编号")
    remark: str | None = Field(None, max_length=200, description="备注")


class MoveLogResponse(BaseModel):
    """移动流水响应"""
    log_id: int
    container_id: str
    from_slot_id: str | None = None
    to_slot_id: str
    move_time: datetime | None = None
    operator_name: str | None = None
    operation_id: str | None = None
    equipment_id: str | None = None
    remark: str | None = None
    created_at: datetime | None = None

    class Config:
        from_attributes = True
