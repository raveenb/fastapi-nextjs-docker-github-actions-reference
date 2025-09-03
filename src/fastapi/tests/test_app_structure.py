"""Test application structure and imports."""

from pathlib import Path


def test_app_directory_structure():
    """Test that all required directories exist."""
    base_path = Path(__file__).parent.parent / "app"

    required_dirs = [
        "api",
        "api/v1",
        "core",
        "models",
        "schemas",
        "services",
        "db",
    ]

    for dir_name in required_dirs:
        dir_path = base_path / dir_name
        assert dir_path.exists(), f"Directory {dir_name} does not exist"
        assert dir_path.is_dir(), f"{dir_name} is not a directory"


def test_app_modules_import():
    """Test that all app modules can be imported."""
    # Main app imports
    from app import __version__

    assert __version__ == "0.1.0"

    # Core imports
    from app.core import config

    assert hasattr(config, "settings")

    # API imports
    from app.api import health, v1

    assert hasattr(health, "router")
    assert hasattr(v1, "router")

    # Model imports
    from app.models import base as models_base

    assert hasattr(models_base, "BaseDBModel")

    # Schema imports
    from app.schemas import base as schemas_base

    assert hasattr(schemas_base, "BaseResponse")

    # Service imports
    from app.services import base as services_base

    assert hasattr(services_base, "BaseService")

    # DB imports
    from app.db import session

    assert hasattr(session, "get_db")


def test_main_app_creation():
    """Test that the main FastAPI app can be created."""
    from app.main import app, create_app

    assert app is not None
    assert app.title == "FastAPI Reference"
    assert app.version == "0.1.0"

    # Test that app factory works
    new_app = create_app()
    assert new_app is not None
