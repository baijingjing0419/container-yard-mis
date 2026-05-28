"""告警 Schema"""
from datetime import datetime
from pydantic import BaseModel, Field


class AlertCreate(BaseModel):
    alert_type: str | None = Field(None, max_length=30, description="overdue/congestion/equipment/schedule")
    alert_level: str | None = Field(None, max_length=10, description="critical/warning/info")
    alert_title: str | None = Field(None, max_length=200)
    alert_content: str | None = None
    related_record_type: str | None = Field(None, max_length=30)
    related_record_id: str | None = Field(None, max_length=30)


class AlertResolve(BaseModel):
    resolved_by: str = Field(..., max_length=20, description="处理人")
    resolution_remark: str | None = Field(None, description="处理备注")


class AlertResponse(BaseModel):
    alert_id: int
    alert_type: str | None = None
    alert_level: str | None = None
    alert_title: str | None = None
    alert_content: str | None = None
    related_record_type: str | None = None
    related_record_id: str | None = None
    is_resolved: bool | None = None
    resolved_by: str | None = None
    resolved_time: datetime | None = None
    resolution_remark: str | None = None
    created_at: datetime | None = None

    class Config:
        from_attributes = True
