"""陆侧出场 Schema"""
from datetime import datetime
from pydantic import BaseModel, Field


class LandOutboundCreate(BaseModel):
    container_id: str = Field(..., max_length=20)
    container_type: str = Field(..., max_length=10)
    container_status: str = Field(default="ready", max_length=20)
    truck_plate: str | None = Field(None, max_length=20)
    driver_name: str | None = Field(None, max_length=50)
    driver_phone: str | None = Field(None, max_length=20)
    pickup_document_no: str | None = Field(None, max_length=50)
    document_type: str | None = Field(None, max_length=20)
    ship_id: str | None = Field(None, max_length=20)
    voyage_no: str | None = Field(None, max_length=20)
    original_slot_id: str | None = Field(None, max_length=20)
    exit_time: datetime | None = None
    gate_pass_time: datetime | None = None
    release_confirm_time: datetime | None = None
    operation_id: str | None = Field(None, max_length=30)
    plan_id: str | None = Field(None, max_length=30)
    process_status: str = Field(default="planned", max_length=20)


class LandOutboundStatusUpdate(BaseModel):
    process_status: str = Field(..., max_length=20, description="新状态: planned/picking/transiting/gate_checking/released/completed")


class LandOutboundResponse(BaseModel):
    container_id: str
    container_type: str
    container_status: str | None = None
    truck_plate: str | None = None
    driver_name: str | None = None
    driver_phone: str | None = None
    pickup_document_no: str | None = None
    document_type: str | None = None
    ship_id: str | None = None
    voyage_no: str | None = None
    original_slot_id: str | None = None
    exit_time: datetime | None = None
    gate_pass_time: datetime | None = None
    release_confirm_time: datetime | None = None
    operation_id: str | None = None
    plan_id: str | None = None
    process_status: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    ship_name: str | None = None
    slot_label: str | None = None

    class Config:
        from_attributes = True
