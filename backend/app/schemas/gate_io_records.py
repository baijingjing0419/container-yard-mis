"""闸口通行记录 Schema"""
from datetime import datetime
from pydantic import BaseModel, Field


class GateRecordCreate(BaseModel):
    record_id: str = Field(..., max_length=30, description="通行记录号")
    gate_lane_no: str | None = Field(None, max_length=10, description="闸口通道号")
    io_type: str = Field(..., max_length=10, description="进出类型: inbound/outbound")
    truck_plate: str = Field(..., max_length=20, description="车牌号码")
    driver_name: str | None = Field(None, max_length=50, description="司机姓名")
    container_id: str | None = Field(None, max_length=20, description="箱号")
    container_type: str | None = Field(None, max_length=10, description="箱型")
    document_no: str | None = Field(None, max_length=50, description="单证号")
    document_verify_result: str = Field(default="passed", max_length=20, description="核验结果")
    damage_check: str = Field(default="完好", max_length=20, description="残损确认")
    damage_remark: str | None = Field(None, description="残损备注")
    entry_time: datetime | None = Field(None, description="入场时间")
    release_status: str = Field(default="pending", max_length=20, description="放行状态")
    release_operator: str | None = Field(None, max_length=50, description="放行人员")
    operation_id: str | None = Field(None, max_length=30, description="关联作业号")
    plan_id: str | None = Field(None, max_length=30, description="关联计划号")


class GateRecordRelease(BaseModel):
    release_status: str = Field(..., max_length=20, description="放行状态: approved/rejected")
    release_operator: str | None = Field(None, max_length=50, description="放行人员")


class GateRecordResponse(BaseModel):
    record_id: str
    gate_lane_no: str | None = None
    io_type: str
    truck_plate: str
    driver_name: str | None = None
    container_id: str | None = None
    container_type: str | None = None
    document_no: str | None = None
    document_verify_result: str | None = None
    damage_check: str | None = None
    damage_remark: str | None = None
    entry_time: datetime | None = None
    exit_time: datetime | None = None
    pass_duration: int | None = None
    release_status: str | None = None
    release_operator: str | None = None
    operation_id: str | None = None
    plan_id: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
