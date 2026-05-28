"""系统日志 Schema"""
from datetime import datetime
from pydantic import BaseModel, Field


class SystemLogCreate(BaseModel):
    log_type: str | None = Field(None, max_length=20)
    user_id: str | None = Field(None, max_length=20)
    operation: str | None = Field(None, max_length=100)
    table_name: str | None = Field(None, max_length=50)
    record_id: str | None = Field(None, max_length=30)
    old_value: str | None = None
    new_value: str | None = None
    ip_address: str | None = Field(None, max_length=50)


class SystemLogResponse(BaseModel):
    log_id: int
    log_type: str | None = None
    user_id: str | None = None
    operation: str | None = None
    table_name: str | None = None
    record_id: str | None = None
    old_value: str | None = None
    new_value: str | None = None
    ip_address: str | None = None
    created_at: datetime | None = None

    class Config:
        from_attributes = True
