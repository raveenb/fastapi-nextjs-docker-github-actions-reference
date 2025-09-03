"""Health check endpoints."""

import time
from datetime import datetime

from fastapi import APIRouter, status
from loguru import logger

from app import __version__
from app.db.session import get_db
from app.schemas.health import HealthResponse, LivenessResponse, ReadinessResponse

router = APIRouter()

# Track service start time for uptime calculation
SERVICE_START_TIME = time.time()


@router.get(
    "/health",
    response_model=HealthResponse,
    status_code=status.HTTP_200_OK,
    summary="Health check",
    description="Check if the service is healthy and responding to requests",
    tags=["health"],
)
async def health_check() -> HealthResponse:
    """
    Health check endpoint.

    Returns the current health status of the service.
    Used by load balancers and monitoring systems.
    """
    logger.debug("Health check requested")
    return HealthResponse(
        status="healthy", timestamp=datetime.utcnow(), version=__version__
    )


@router.get(
    "/ready",
    response_model=ReadinessResponse,
    status_code=status.HTTP_200_OK,
    summary="Readiness check",
    description="Check if the service is ready to accept traffic",
    tags=["health"],
)
async def readiness_check() -> ReadinessResponse:
    """
    Readiness check endpoint.

    Verifies that all required services and dependencies are available.
    Used by orchestrators to determine if the service can receive traffic.
    """
    logger.debug("Readiness check requested")

    checks = {}

    # Check database connectivity (mock for now)
    try:
        async with get_db() as db:
            # In a real app, you'd perform an actual database query here
            await db.commit()  # Just test the session works
            checks["database"] = True
    except Exception as e:
        logger.error(f"Database check failed: {e}")
        checks["database"] = False

    # Check if configuration is loaded
    checks["configuration"] = True  # Always true for now

    # Determine overall readiness
    all_ready = all(checks.values())

    return ReadinessResponse(
        status="ready" if all_ready else "not_ready",
        timestamp=datetime.utcnow(),
        checks=checks,
    )


@router.get(
    "/live",
    response_model=LivenessResponse,
    status_code=status.HTTP_200_OK,
    summary="Liveness check",
    description="Check if the service is alive and not in a deadlock state",
    tags=["health"],
)
async def liveness_check() -> LivenessResponse:
    """
    Liveness check endpoint.

    Simple check to verify the service is alive and responding.
    Used by orchestrators to detect and restart unhealthy instances.
    """
    logger.debug("Liveness check requested")

    uptime = time.time() - SERVICE_START_TIME

    return LivenessResponse(
        status="alive", timestamp=datetime.utcnow(), uptime_seconds=uptime
    )
