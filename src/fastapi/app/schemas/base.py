"""Base schema classes."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict


class BaseResponse(BaseModel):
    """Base response schema."""

    model_config = ConfigDict(
        from_attributes=True,
        validate_assignment=True,
        arbitrary_types_allowed=True,
        str_strip_whitespace=True,
    )


class TimestampMixin(BaseModel):
    """Mixin for timestamp fields."""

    created_at: datetime
    updated_at: datetime | None = None


class IDMixin(BaseModel):
    """Mixin for ID field."""

    id: int
