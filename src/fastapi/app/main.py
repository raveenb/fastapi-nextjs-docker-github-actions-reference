"""Main FastAPI application module."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger

from app.api import config, health, v1
from app.core.config import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    logger.info(f"Starting {settings.PROJECT_NAME} v{settings.PROJECT_VERSION}")
    logger.info(f"Environment: {settings.ENVIRONMENT.value}")
    logger.info(f"Debug mode: {settings.DEBUG}")
    logger.info(f"API docs: {'enabled' if settings.FEATURE_API_DOCS else 'disabled'}")

    # Log configuration summary
    logger.debug("Configuration loaded successfully")

    yield

    # Shutdown
    logger.info("Shutting down application")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    # Conditionally enable API documentation
    docs_url = "/docs" if settings.FEATURE_API_DOCS else None
    redoc_url = "/redoc" if settings.FEATURE_API_DOCS else None
    openapi_url = (
        f"{settings.API_V1_PREFIX}/openapi.json" if settings.FEATURE_API_DOCS else None
    )

    app = FastAPI(
        title=settings.PROJECT_NAME,
        version=settings.PROJECT_VERSION,
        debug=settings.DEBUG,
        openapi_url=openapi_url,
        docs_url=docs_url,
        redoc_url=redoc_url,
        lifespan=lifespan,
    )

    # Configure CORS with settings
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=settings.ALLOW_CREDENTIALS,
        allow_methods=settings.ALLOW_METHODS,
        allow_headers=settings.ALLOW_HEADERS,
    )

    # Include routers
    app.include_router(health.router, tags=["health"])
    app.include_router(config.router, tags=["configuration"])
    app.include_router(v1.router, prefix=settings.API_V1_PREFIX)

    return app


app = create_app()
