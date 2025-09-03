"""Base service class."""

from typing import Generic, TypeVar

from loguru import logger

T = TypeVar("T")


class BaseService(Generic[T]):
    """Base service class with common operations."""

    def __init__(self, model_name: str):
        """Initialize the service."""
        self.model_name = model_name
        logger.debug(f"Initialized {model_name} service")

    async def get_all(self, skip: int = 0, limit: int = 100) -> list[T]:
        """Get all items with pagination."""
        logger.debug(f"Getting all {self.model_name} items")
        # Placeholder implementation
        return []

    async def get_by_id(self, item_id: int) -> T | None:
        """Get item by ID."""
        logger.debug(f"Getting {self.model_name} with ID: {item_id}")
        # Placeholder implementation
        return None

    async def create(self, item: T) -> T:
        """Create new item."""
        logger.debug(f"Creating new {self.model_name}")
        # Placeholder implementation
        return item

    async def update(self, item_id: int, item: T) -> T | None:
        """Update existing item."""
        logger.debug(f"Updating {self.model_name} with ID: {item_id}")
        # Placeholder implementation
        return item

    async def delete(self, item_id: int) -> bool:
        """Delete item."""
        logger.debug(f"Deleting {self.model_name} with ID: {item_id}")
        # Placeholder implementation
        return True
