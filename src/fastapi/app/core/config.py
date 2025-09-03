"""Application configuration module."""

import json
import secrets
from enum import Enum
from functools import lru_cache
from typing import Any

from loguru import logger
from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Environment(str, Enum):
    """Application environment."""

    DEVELOPMENT = "development"
    TESTING = "testing"
    STAGING = "staging"
    PRODUCTION = "production"


class LogLevel(str, Enum):
    """Logging levels."""

    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class LogFormat(str, Enum):
    """Logging formats."""

    JSON = "json"
    TEXT = "text"


class Settings(BaseSettings):
    """Application settings with validation and environment support."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",  # Ignore extra environment variables
    )

    # Environment
    ENVIRONMENT: Environment = Field(
        default=Environment.DEVELOPMENT,
        description="Application environment",
    )

    # Project settings
    PROJECT_NAME: str = Field(
        default="FastAPI Reference",
        description="Project name",
    )
    PROJECT_VERSION: str = Field(
        default="0.1.0",
        description="Project version",
    )
    API_V1_PREFIX: str = Field(
        default="/api/v1",
        description="API v1 prefix",
    )
    DEBUG: bool = Field(
        default=False,
        description="Debug mode",
    )

    # Server settings
    HOST: str = Field(
        default="0.0.0.0",
        description="Server host",
    )
    PORT: int = Field(
        default=8000,
        ge=1,
        le=65535,
        description="Server port",
    )
    RELOAD: bool = Field(
        default=False,
        description="Auto-reload on code changes",
    )
    WORKERS: int = Field(
        default=1,
        ge=1,
        description="Number of worker processes",
    )

    # CORS settings
    ALLOWED_ORIGINS: list[str] = Field(
        default=["http://localhost:3000", "http://localhost:8000"],
        description="Allowed CORS origins",
    )
    ALLOW_CREDENTIALS: bool = Field(
        default=True,
        description="Allow credentials in CORS",
    )
    ALLOW_METHODS: list[str] = Field(
        default=["*"],
        description="Allowed HTTP methods",
    )
    ALLOW_HEADERS: list[str] = Field(
        default=["*"],
        description="Allowed HTTP headers",
    )

    # Database settings
    DATABASE_URL: str = Field(
        default="sqlite:///./app.db",
        description="Database connection URL",
    )
    DATABASE_POOL_SIZE: int = Field(
        default=5,
        ge=1,
        description="Database connection pool size",
    )
    DATABASE_MAX_OVERFLOW: int = Field(
        default=10,
        ge=0,
        description="Maximum overflow connections",
    )

    # Redis settings (for future caching)
    REDIS_URL: str | None = Field(
        default=None,
        description="Redis connection URL",
    )

    # Security settings
    SECRET_KEY: str = Field(
        default_factory=lambda: secrets.token_urlsafe(32),
        description="Secret key for signing",
    )
    ALGORITHM: str = Field(
        default="HS256",
        description="JWT algorithm",
    )
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(
        default=30,
        ge=1,
        description="Access token expiration in minutes",
    )
    REFRESH_TOKEN_EXPIRE_DAYS: int = Field(
        default=7,
        ge=1,
        description="Refresh token expiration in days",
    )

    # Logging
    LOG_LEVEL: LogLevel = Field(
        default=LogLevel.INFO,
        description="Logging level",
    )
    LOG_FORMAT: LogFormat = Field(
        default=LogFormat.JSON,
        description="Logging format",
    )

    # External Services
    EXTERNAL_API_KEY: str | None = Field(
        default=None,
        description="External API key",
    )
    EXTERNAL_API_URL: str | None = Field(
        default=None,
        description="External API URL",
    )

    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = Field(
        default=False,
        description="Enable rate limiting",
    )
    RATE_LIMIT_REQUESTS: int = Field(
        default=100,
        ge=1,
        description="Maximum requests per period",
    )
    RATE_LIMIT_PERIOD: int = Field(
        default=60,
        ge=1,
        description="Rate limit period in seconds",
    )

    # Monitoring
    SENTRY_DSN: str | None = Field(
        default=None,
        description="Sentry DSN for error tracking",
    )
    OPENTELEMETRY_ENABLED: bool = Field(
        default=False,
        description="Enable OpenTelemetry",
    )
    OPENTELEMETRY_ENDPOINT: str | None = Field(
        default=None,
        description="OpenTelemetry collector endpoint",
    )

    # Feature Flags
    FEATURE_API_DOCS: bool = Field(
        default=True,
        description="Enable API documentation",
    )
    FEATURE_METRICS: bool = Field(
        default=False,
        description="Enable metrics endpoint",
    )
    FEATURE_ADMIN_PANEL: bool = Field(
        default=False,
        description="Enable admin panel",
    )

    @field_validator("ALLOWED_ORIGINS", mode="before")
    @classmethod
    def parse_cors_origins(cls, v: Any) -> list[str]:
        """Parse CORS origins from string or list."""
        if isinstance(v, str):
            # Try to parse as JSON array
            if v.startswith("["):
                try:
                    return json.loads(v)
                except json.JSONDecodeError:
                    pass
            # Parse as comma-separated list
            return [origin.strip() for origin in v.split(",")]
        return v

    @model_validator(mode="after")
    def set_debug_from_environment(self) -> "Settings":
        """Set debug mode based on environment."""
        if self.ENVIRONMENT == Environment.DEVELOPMENT:
            self.DEBUG = True
            self.RELOAD = True
        elif self.ENVIRONMENT == Environment.PRODUCTION:
            self.DEBUG = False
            self.RELOAD = False
        return self

    @model_validator(mode="after")
    def validate_production_settings(self) -> "Settings":
        """Validate critical settings for production."""
        if self.ENVIRONMENT == Environment.PRODUCTION:
            # Check for default secret key
            if self.SECRET_KEY == "your-secret-key-here":
                raise ValueError("SECRET_KEY must be changed for production")

            # Ensure API docs are disabled in production (optional)
            if self.FEATURE_API_DOCS:
                logger.warning("API documentation is enabled in production")

            # Ensure proper worker configuration
            if self.WORKERS < 2:
                logger.warning("Consider using multiple workers in production")

        return self

    @property
    def is_development(self) -> bool:
        """Check if running in development mode."""
        return self.ENVIRONMENT == Environment.DEVELOPMENT

    @property
    def is_testing(self) -> bool:
        """Check if running in testing mode."""
        return self.ENVIRONMENT == Environment.TESTING

    @property
    def is_production(self) -> bool:
        """Check if running in production mode."""
        return self.ENVIRONMENT == Environment.PRODUCTION

    def get_database_url(self, async_driver: bool = False) -> str:
        """Get database URL with optional async driver."""
        if async_driver and self.DATABASE_URL.startswith("postgresql://"):
            return self.DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://")
        return self.DATABASE_URL

    def to_dict(self, exclude_sensitive: bool = True) -> dict[str, Any]:
        """Convert settings to dictionary."""
        data = self.model_dump()
        if exclude_sensitive:
            sensitive_keys = {
                "SECRET_KEY",
                "DATABASE_URL",
                "REDIS_URL",
                "EXTERNAL_API_KEY",
                "SENTRY_DSN",
            }
            for key in sensitive_keys:
                if key in data and data[key]:
                    data[key] = "***REDACTED***"
        return data


@lru_cache
def get_settings() -> Settings:
    """Get cached settings instance."""
    settings = Settings()
    logger.info(f"Loaded settings for environment: {settings.ENVIRONMENT}")
    return settings


# Create global settings instance
settings = get_settings()
