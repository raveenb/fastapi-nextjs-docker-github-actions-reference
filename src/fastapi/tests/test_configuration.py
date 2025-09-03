"""Test configuration management."""

import os
from unittest.mock import patch

import pytest
from fastapi import status
from fastapi.testclient import TestClient


def test_default_settings():
    """Test default settings initialization."""
    from app.core.config import Settings

    settings = Settings()

    assert settings.PROJECT_NAME == "FastAPI Reference"
    assert settings.PROJECT_VERSION == "0.1.0"
    assert settings.ENVIRONMENT.value == "development"
    assert settings.PORT == 8000
    # In development environment, DEBUG is automatically set to True
    assert settings.DEBUG is True  # Set by validator in development


def test_environment_based_settings():
    """Test environment-based configuration."""
    from app.core.config import Environment, Settings

    # Development environment
    dev_settings = Settings(ENVIRONMENT=Environment.DEVELOPMENT)
    assert dev_settings.DEBUG is True
    assert dev_settings.RELOAD is True

    # Production environment
    prod_settings = Settings(
        ENVIRONMENT=Environment.PRODUCTION, SECRET_KEY="production-secret-key-123"
    )
    assert prod_settings.DEBUG is False
    assert prod_settings.RELOAD is False


def test_production_validation():
    """Test production settings validation."""
    from app.core.config import Environment, Settings

    # Should raise error with default secret key
    with pytest.raises(ValueError, match="SECRET_KEY must be changed"):
        Settings(ENVIRONMENT=Environment.PRODUCTION, SECRET_KEY="your-secret-key-here")


def test_cors_origins_parsing():
    """Test CORS origins parsing from different formats."""
    from app.core.config import Settings

    # JSON array string
    settings1 = Settings(
        ALLOWED_ORIGINS='["http://localhost:3000","http://localhost:8000"]'
    )
    assert settings1.ALLOWED_ORIGINS == [
        "http://localhost:3000",
        "http://localhost:8000",
    ]

    # Comma-separated string
    settings2 = Settings(ALLOWED_ORIGINS="http://localhost:3000,http://localhost:8000")
    assert settings2.ALLOWED_ORIGINS == [
        "http://localhost:3000",
        "http://localhost:8000",
    ]

    # List directly
    settings3 = Settings(
        ALLOWED_ORIGINS=["http://localhost:3000", "http://localhost:8000"]
    )
    assert settings3.ALLOWED_ORIGINS == [
        "http://localhost:3000",
        "http://localhost:8000",
    ]


def test_database_url_conversion():
    """Test database URL conversion for async drivers."""
    from app.core.config import Settings

    settings = Settings(DATABASE_URL="postgresql://user:pass@localhost/db")

    # Sync URL
    assert (
        settings.get_database_url(async_driver=False)
        == "postgresql://user:pass@localhost/db"
    )

    # Async URL
    assert (
        settings.get_database_url(async_driver=True)
        == "postgresql+asyncpg://user:pass@localhost/db"
    )

    # Non-PostgreSQL URL should not change
    settings2 = Settings(DATABASE_URL="sqlite:///./app.db")
    assert settings2.get_database_url(async_driver=True) == "sqlite:///./app.db"


def test_settings_to_dict():
    """Test settings conversion to dictionary with sensitive data redaction."""
    from app.core.config import Settings

    settings = Settings(
        SECRET_KEY="super-secret-key",
        DATABASE_URL="postgresql://user:password@localhost/db",
        EXTERNAL_API_KEY="api-key-123",
    )

    # With sensitive data redacted
    data = settings.to_dict(exclude_sensitive=True)
    assert data["SECRET_KEY"] == "***REDACTED***"
    assert data["DATABASE_URL"] == "***REDACTED***"
    assert data["EXTERNAL_API_KEY"] == "***REDACTED***"

    # Without redaction
    data = settings.to_dict(exclude_sensitive=False)
    assert data["SECRET_KEY"] == "super-secret-key"
    assert data["DATABASE_URL"] == "postgresql://user:password@localhost/db"
    assert data["EXTERNAL_API_KEY"] == "api-key-123"


def test_environment_properties():
    """Test environment property helpers."""
    from app.core.config import Environment, Settings

    dev = Settings(ENVIRONMENT=Environment.DEVELOPMENT)
    assert dev.is_development is True
    assert dev.is_production is False
    assert dev.is_testing is False

    prod = Settings(ENVIRONMENT=Environment.PRODUCTION, SECRET_KEY="production-key")
    assert prod.is_development is False
    assert prod.is_production is True
    assert prod.is_testing is False

    test = Settings(ENVIRONMENT=Environment.TESTING)
    assert test.is_development is False
    assert test.is_production is False
    assert test.is_testing is True


def test_config_endpoint_access():
    """Test configuration endpoint access control."""
    from app.core.config import Environment
    from app.main import create_app

    # Test with development environment - should allow access
    with patch("app.api.config.settings") as mock_settings:
        mock_settings.ENVIRONMENT = Environment.DEVELOPMENT
        mock_settings.FEATURE_ADMIN_PANEL = False
        mock_settings.to_dict.return_value = {"test": "data"}

        app = create_app()
        client = TestClient(app)
        response = client.get("/config")
        assert response.status_code == status.HTTP_200_OK
        assert response.json() == {"test": "data"}

    # Test with production without admin panel - should deny access
    with patch("app.api.config.settings") as mock_settings:
        mock_settings.ENVIRONMENT = Environment.PRODUCTION
        mock_settings.FEATURE_ADMIN_PANEL = False

        app = create_app()
        client = TestClient(app)
        response = client.get("/config")
        assert response.status_code == status.HTTP_403_FORBIDDEN


def test_environment_endpoint():
    """Test environment information endpoint."""
    from app.main import app

    client = TestClient(app)
    response = client.get("/config/environment")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "environment" in data
    assert "debug" in data
    assert "version" in data


def test_feature_flags_endpoint():
    """Test feature flags endpoint."""
    from app.main import app

    client = TestClient(app)
    response = client.get("/config/features")

    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert "api_docs" in data
    assert "metrics" in data
    assert "admin_panel" in data
    assert "rate_limiting" in data
    assert "opentelemetry" in data


def test_env_file_loading():
    """Test loading configuration from environment variables."""
    # Set environment variables
    os.environ["PROJECT_NAME"] = "Test Project"
    os.environ["PORT"] = "9000"
    os.environ["WORKERS"] = "4"

    try:
        from app.core.config import Settings

        settings = Settings()
        assert settings.PROJECT_NAME == "Test Project"
        assert settings.PORT == 9000
        assert settings.WORKERS == 4
    finally:
        # Clean up
        del os.environ["PROJECT_NAME"]
        del os.environ["PORT"]
        del os.environ["WORKERS"]


def test_settings_validation():
    """Test settings validation constraints."""
    from app.core.config import Settings

    # Valid port range
    Settings(PORT=8080)  # Should work

    # Invalid port - too low
    with pytest.raises(ValueError):
        Settings(PORT=0)

    # Invalid port - too high
    with pytest.raises(ValueError):
        Settings(PORT=70000)

    # Valid workers
    Settings(WORKERS=4)  # Should work

    # Invalid workers
    with pytest.raises(ValueError):
        Settings(WORKERS=0)
