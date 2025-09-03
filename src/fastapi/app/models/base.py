"""Base model classes."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class BaseDBModel(BaseModel):
    """Base model for database entities."""

    model_config = ConfigDict(from_attributes=True)

    id: int = Field(..., description="Unique identifier")
    created_at: datetime = Field(
        default_factory=datetime.utcnow, description="Creation timestamp"
    )
    updated_at: datetime | None = Field(None, description="Last update timestamp")
