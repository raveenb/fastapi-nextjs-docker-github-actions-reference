"""Configuration management endpoints."""

from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from loguru import logger

from app.core.config import Environment, settings

router = APIRouter()


def check_config_access() -> None:
    """Check if configuration endpoint is accessible."""
    if (
        settings.ENVIRONMENT == Environment.PRODUCTION
        and not settings.FEATURE_ADMIN_PANEL
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Configuration endpoint is disabled in production",
        )


@router.get(
    "/config",
    response_model=dict[str, Any],
    status_code=status.HTTP_200_OK,
    summary="Get configuration",
    description="Get current application configuration (non-sensitive)",
    tags=["configuration"],
    dependencies=[Depends(check_config_access)],
)
async def get_configuration() -> dict[str, Any]:
    """
    Get current application configuration.

    Returns non-sensitive configuration values.
    Sensitive values are redacted for security.
    """
    logger.debug("Configuration requested")
    return settings.to_dict(exclude_sensitive=True)


@router.get(
    "/config/environment",
    response_model=dict[str, str],
    status_code=status.HTTP_200_OK,
    summary="Get environment info",
    description="Get current environment information",
    tags=["configuration"],
)
async def get_environment() -> dict[str, str]:
    """
    Get environment information.

    Returns the current environment and mode.
    """
    return {
        "environment": settings.ENVIRONMENT.value,
        "debug": str(settings.DEBUG),
        "version": settings.PROJECT_VERSION,
    }


@router.get(
    "/config/features",
    response_model=dict[str, bool],
    status_code=status.HTTP_200_OK,
    summary="Get feature flags",
    description="Get current feature flag states",
    tags=["configuration"],
)
async def get_feature_flags() -> dict[str, bool]:
    """
    Get feature flag states.

    Returns the current state of all feature flags.
    """
    return {
        "api_docs": settings.FEATURE_API_DOCS,
        "metrics": settings.FEATURE_METRICS,
        "admin_panel": settings.FEATURE_ADMIN_PANEL,
        "rate_limiting": settings.RATE_LIMIT_ENABLED,
        "opentelemetry": settings.OPENTELEMETRY_ENABLED,
    }
