"""Test that core dependencies are installed and working."""

import sys


def test_fastapi_import():
    """Test that FastAPI can be imported."""
    import fastapi
    
    assert fastapi.__version__
    assert hasattr(fastapi, "FastAPI")


def test_uvicorn_import():
    """Test that uvicorn can be imported."""
    import uvicorn
    
    assert uvicorn.__version__
    assert hasattr(uvicorn, "run")


def test_pydantic_import():
    """Test that pydantic can be imported."""
    import pydantic
    
    assert pydantic.__version__
    assert hasattr(pydantic, "BaseModel")


def test_pydantic_settings_import():
    """Test that pydantic-settings can be imported."""
    import pydantic_settings
    
    assert hasattr(pydantic_settings, "BaseSettings")


def test_loguru_import():
    """Test that loguru can be imported."""
    import loguru
    
    assert hasattr(loguru, "logger")


def test_dotenv_import():
    """Test that python-dotenv can be imported."""
    import dotenv
    
    assert hasattr(dotenv, "load_dotenv")


def test_dev_dependencies():
    """Test that dev dependencies are available."""
    import pytest
    import black
    import ruff
    import mypy
    
    assert pytest.__version__
    assert black.__version__
    assert ruff  # ruff doesn't expose __version__ directly
    assert mypy  # mypy is available for type checking