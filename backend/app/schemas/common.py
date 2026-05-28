"""通用 Schema - 分页响应、错误响应等复用结构"""
from typing import Generic, TypeVar
from pydantic import BaseModel

T = TypeVar("T")


class PaginatedResponse(BaseModel, Generic[T]):
    """通用分页响应结构，包裹任意类型的数据列表"""
    items: list[T]
    total: int
    page: int
    page_size: int

    class Config:
        from_attributes = True
