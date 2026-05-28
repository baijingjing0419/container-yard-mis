"""海侧码头统筹 Schema"""
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class TerminalIOCreate(BaseModel):
    io_record_id: str = Field(..., max_length=30)
    voyage_no: str = Field(..., max_length=20)
    ship_id: str = Field(..., max_length=20)
    berth_time: datetime | None = None
    departure_time: datetime | None = None
    inbound_total: int = Field(default=0)
    outbound_total: int = Field(default=0)
    operation_sequence: str | None = None
    stowage_plan: str | None = None
    operation_progress: Decimal | None = Field(default=0)
    assigned_quay_cranes: str | None = Field(None, max_length=100)
    assigned_yard_cranes: str | None = Field(None, max_length=100)
    assigned_trucks: str | None = Field(None, max_length=100)
    operation_status: str = Field(default="planned", max_length=20)


class TerminalIOProgressUpdate(BaseModel):
    operation_progress: Decimal = Field(..., description="进度百分比")
    operation_status: str | None = Field(None, max_length=20, description="作业状态")


class TerminalIOResponse(BaseModel):
    io_record_id: str
    voyage_no: str
    ship_id: str
    berth_time: datetime | None = None
    departure_time: datetime | None = None
    inbound_total: int | None = None
    outbound_total: int | None = None
    operation_sequence: str | None = None
    stowage_plan: str | None = None
    operation_progress: Decimal | None = None
    assigned_quay_cranes: str | None = None
    assigned_yard_cranes: str | None = None
    assigned_trucks: str | None = None
    operation_status: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    ship_name: str | None = None

    class Config:
        from_attributes = True
