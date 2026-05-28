"""陆侧作业计划 Schema"""
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class LandPlanCreate(BaseModel):
    plan_id: str = Field(..., max_length=30)
    plan_type: str = Field(..., max_length=20)
    planned_start_time: datetime | None = None
    planned_end_time: datetime | None = None
    actual_start_time: datetime | None = None
    actual_end_time: datetime | None = None
    planned_container_count: int = Field(default=0)
    actual_container_count: int = Field(default=0)
    assigned_gate_lanes: str | None = Field(None, max_length=50)
    plan_status: str = Field(default="draft", max_length=20)
    completion_rate: Decimal | None = None
    gate_io_record_id: str | None = Field(None, max_length=30)


class LandPlanStatusUpdate(BaseModel):
    plan_status: str = Field(..., max_length=20)
    completion_rate: Decimal | None = None


class LandPlanResponse(BaseModel):
    plan_id: str
    plan_type: str
    planned_start_time: datetime | None = None
    planned_end_time: datetime | None = None
    actual_start_time: datetime | None = None
    actual_end_time: datetime | None = None
    planned_container_count: int | None = None
    actual_container_count: int | None = None
    assigned_gate_lanes: str | None = None
    plan_status: str | None = None
    completion_rate: Decimal | None = None
    gate_io_record_id: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
