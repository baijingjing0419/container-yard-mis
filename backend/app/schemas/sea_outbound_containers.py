"""海侧出场 Schema"""
from datetime import datetime
from pydantic import BaseModel, Field


class SeaOutboundCreate(BaseModel):
    container_id: str = Field(..., max_length=20)
    container_type: str = Field(..., max_length=10)
    container_status: str = Field(default="loaded", max_length=20)
    ship_id: str = Field(..., max_length=20)
    voyage_no: str = Field(..., max_length=20)
    stowage_position: str | None = Field(None, max_length=20)
    exit_time: datetime | None = None
    original_slot_id: str | None = Field(None, max_length=20)
    load_complete_time: datetime | None = None
    document_info: str | None = None
    customs_status: str = Field(default="cleared", max_length=20)
    operation_id: str | None = Field(None, max_length=30)
    plan_id: str | None = Field(None, max_length=30)
    yard_crane: str | None = Field(None, max_length=20)
    transfer_truck: str | None = Field(None, max_length=20)
    load_crane: str | None = Field(None, max_length=20)
    process_status: str = Field(default="planned", max_length=20)


class SeaOutboundStatusUpdate(BaseModel):
    process_status: str = Field(..., max_length=20)


class SeaOutboundResponse(BaseModel):
    container_id: str
    container_type: str | None = None
    container_status: str | None = None
    ship_id: str
    voyage_no: str
    stowage_position: str | None = None
    exit_time: datetime | None = None
    original_slot_id: str | None = None
    load_complete_time: datetime | None = None
    document_info: str | None = None
    customs_status: str | None = None
    operation_id: str | None = None
    plan_id: str | None = None
    yard_crane: str | None = None
    transfer_truck: str | None = None
    load_crane: str | None = None
    process_status: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None
    ship_name: str | None = None
    slot_label: str | None = None

    class Config:
        from_attributes = True
