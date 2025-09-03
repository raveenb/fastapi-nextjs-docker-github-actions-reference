"""Test health check endpoints."""

import time
from datetime import datetime

import pytest
from fastapi import status
from fastapi.testclient import TestClient


@pytest.fixture
def client():
    """Create a test client."""
    from app.main import app

    return TestClient(app)


def test_health_endpoint(client):
    """Test the /health endpoint."""
    response = client.get("/health")

    assert response.status_code == status.HTTP_200_OK

    data = response.json()
    assert data["status"] == "healthy"
    assert "timestamp" in data
    assert "service" in data
    assert data["service"] == "fastapi-backend"
    assert "version" in data

    # Verify timestamp is valid ISO format
    timestamp = datetime.fromisoformat(data["timestamp"].replace("Z", "+00:00"))
    assert isinstance(timestamp, datetime)


def test_readiness_endpoint(client):
    """Test the /ready endpoint."""
    response = client.get("/ready")

    assert response.status_code == status.HTTP_200_OK

    data = response.json()
    assert data["status"] in ["ready", "not_ready"]
    assert "timestamp" in data
    assert "checks" in data
    assert isinstance(data["checks"], dict)

    # Verify all expected checks are present
    assert "database" in data["checks"]
    assert "configuration" in data["checks"]

    # All checks should be boolean
    for check_name, check_value in data["checks"].items():
        assert isinstance(check_value, bool), f"Check {check_name} is not boolean"


def test_liveness_endpoint(client):
    """Test the /live endpoint."""
    # Small delay to ensure uptime > 0
    time.sleep(0.1)

    response = client.get("/live")

    assert response.status_code == status.HTTP_200_OK

    data = response.json()
    assert data["status"] == "alive"
    assert "timestamp" in data
    assert "uptime_seconds" in data
    assert data["uptime_seconds"] > 0
    assert isinstance(data["uptime_seconds"], float)


def test_openapi_documentation(client):
    """Test that health endpoints are documented in OpenAPI."""
    response = client.get("/api/v1/openapi.json")
    assert response.status_code == status.HTTP_200_OK

    openapi_spec = response.json()
    paths = openapi_spec.get("paths", {})

    # Check that all health endpoints are documented
    assert "/health" in paths
    assert "/ready" in paths
    assert "/live" in paths

    # Verify endpoint metadata
    health_endpoint = paths["/health"]["get"]
    assert health_endpoint["summary"] == "Health check"
    assert "health" in health_endpoint["tags"]

    ready_endpoint = paths["/ready"]["get"]
    assert ready_endpoint["summary"] == "Readiness check"

    live_endpoint = paths["/live"]["get"]
    assert live_endpoint["summary"] == "Liveness check"


@pytest.mark.asyncio
async def test_health_response_schema():
    """Test health response schema validation."""
    from app.schemas.health import HealthResponse

    # Valid response
    response = HealthResponse(
        status="healthy",
        timestamp=datetime.utcnow(),
        service="test-service",
        version="1.0.0",
    )
    assert response.status == "healthy"
    assert response.service == "test-service"
    assert response.version == "1.0.0"

    # Test with default service
    response = HealthResponse(
        status="healthy",
        version="1.0.0",
    )
    assert response.service == "fastapi-backend"


@pytest.mark.asyncio
async def test_readiness_response_schema():
    """Test readiness response schema validation."""
    from app.schemas.health import ReadinessResponse

    response = ReadinessResponse(
        status="ready",
        checks={
            "database": True,
            "cache": False,
            "external_api": True,
        },
    )
    assert response.status == "ready"
    assert len(response.checks) == 3
    assert response.checks["database"] is True
    assert response.checks["cache"] is False


@pytest.mark.asyncio
async def test_liveness_response_schema():
    """Test liveness response schema validation."""
    from app.schemas.health import LivenessResponse

    response = LivenessResponse(
        status="alive",
        uptime_seconds=123.45,
    )
    assert response.status == "alive"
    assert response.uptime_seconds == 123.45
