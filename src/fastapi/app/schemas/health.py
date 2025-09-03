"""Health check response schemas."""

from datetime import datetime

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    """Health check response schema."""

    status: str = Field(..., description="Health status", examples=["healthy"])
    timestamp: datetime = Field(
        default_factory=datetime.utcnow, description="Response timestamp"
    )
    service: str = Field(default="fastapi-backend", description="Service identifier")
    version: str = Field(..., description="Service version")


class ReadinessResponse(BaseModel):
    """Readiness check response schema."""

    status: str = Field(..., description="Readiness status", examples=["ready"])
    timestamp: datetime = Field(
        default_factory=datetime.utcnow, description="Response timestamp"
    )
    checks: dict[str, bool] = Field(
        default_factory=dict, description="Individual readiness checks"
    )


class LivenessResponse(BaseModel):
    """Liveness check response schema."""

    status: str = Field(..., description="Liveness status", examples=["alive"])
    timestamp: datetime = Field(
        default_factory=datetime.utcnow, description="Response timestamp"
    )
    uptime_seconds: float = Field(..., description="Service uptime in seconds")
