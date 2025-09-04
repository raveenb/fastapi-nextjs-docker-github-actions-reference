"""Version endpoint for the API."""

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()


class VersionInfo(BaseModel):
    """Version information response model."""
    
    version: str
    api_version: str
    environment: str


@router.get("/version", response_model=VersionInfo)
async def get_version() -> VersionInfo:
    """Get API version information.
    
    Returns:
        VersionInfo: Current version details
    """
    return VersionInfo(
        version="0.0.1",
        api_version="v1",
        environment="production"
    )