"""海侧作业计划 Schema"""
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class SeaPlanCreate(BaseModel):
    plan_id: str = Field(..., max_length=30)
    plan_type: str = Field(..., max_length=20, description="discharge/load")
    voyage_no: str = Field(..., max_length=20)
    ship_id: str = Field(..., max_length=20)
    planned_berth_time: datetime | None = None
    planned_depart_time: datetime | None = None
    actual_berth_time: datetime | None = None
    actual_depart_time: datetime | None = None
    planned_inbound: int = Field(default=0)
    planned_outbound: int = Field(default=0)
    actual_inbound: int = Field(default=0)
    actual_outbound: int = Field(default=0)
    assigned_quay_cranes: str | None = Field(None, max_length=100)
    assigned_yard_cranes: str | None = Field(None, max_length=100)
    assigned_trucks: str | None = Field(None, max_length=100)
    plan_status: str = Field(default="draft", max_length=20)
    completion_rate: Decimal | None = None
    sea_io_record_id: str | None = Field(None, max_length=30)


class SeaPlanStatusUpdate(BaseModel):
    plan_status: str = Field(..., max_length=20)
    completion_rate: Decimal | None = None


class SeaPlanResponse(BaseModel):
    plan_id: str
    plan_type: str
    voyage_no: str
    ship_id: str
    planned_berth_time: datetime | None = None
    planned_depart_time: datetime | None = None
    actual_berth_time: datetime | None = None
    actual_depart_time: datetime | None = None
    planned_inbound: int | None = None
    planned_outbound: int | None = None
    actual_inbound: int | None = None
    actual_outbound: int | None = None
    assigned_quay_cranes: str | None = None
    assigned_yard_cranes: str | None = None
    assigned_trucks: str | None = None
    plan_status: str | None = None
    completion_rate: Decimal | None = None
    sea_io_record_id: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    ship_name: str | None = None

    class Config:
        from_attributes = True
