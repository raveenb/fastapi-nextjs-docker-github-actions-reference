"""Test to verify the project setup is working correctly."""


def test_project_setup():
    """Test that the project is set up correctly."""
    assert True, "Project setup is working"


def test_python_version():
    """Test that we're using the correct Python version."""
    import sys

    assert sys.version_info >= (3, 11), "Python 3.11+ is required"
