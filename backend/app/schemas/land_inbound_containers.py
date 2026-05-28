"""陆侧进箱 Schema"""
from datetime import datetime
from pydantic import BaseModel, Field


class LandInboundCreate(BaseModel):
    container_id: str = Field(..., max_length=20)
    container_type: str = Field(..., max_length=10)
    container_status: str = Field(default="intact", max_length=20)
    truck_plate: str | None = Field(None, max_length=20)
    driver_name: str | None = Field(None, max_length=50)
    driver_phone: str | None = Field(None, max_length=20)
    document_no: str | None = Field(None, max_length=50)
    document_type: str | None = Field(None, max_length=20)
    ship_id: str | None = Field(None, max_length=20)
    voyage_no: str | None = Field(None, max_length=20)
    entry_time: datetime | None = None
    gate_pass_time: datetime | None = None
    target_slot_id: str | None = Field(None, max_length=20)
    actual_slot_id: str | None = Field(None, max_length=20)
    damage_check: str = Field(default="完好", max_length=20)
    damage_photo_url: str | None = Field(None, max_length=255)
    operation_id: str | None = Field(None, max_length=30)
    plan_id: str | None = Field(None, max_length=30)
    process_status: str = Field(default="pending", max_length=20)


class LandInboundStatusUpdate(BaseModel):
    process_status: str = Field(..., max_length=20)


class LandInboundResponse(BaseModel):
    container_id: str
    container_type: str
    container_status: str | None = None
    truck_plate: str | None = None
    driver_name: str | None = None
    driver_phone: str | None = None
    document_no: str | None = None
    document_type: str | None = None
    ship_id: str | None = None
    voyage_no: str | None = None
    entry_time: datetime | None = None
    gate_pass_time: datetime | None = None
    target_slot_id: str | None = None
    actual_slot_id: str | None = None
    damage_check: str | None = None
    damage_photo_url: str | None = None
    operation_id: str | None = None
    plan_id: str | None = None
    process_status: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    ship_name: str | None = None
    target_slot_label: str | None = None
    actual_slot_label: str | None = None

    class Config:
        from_attributes = True
