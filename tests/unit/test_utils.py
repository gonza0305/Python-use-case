"""Unit tests for utility functions."""
import pytest
from pathlib import Path
from src.utils import (
    setup_logger,
    load_config,
    ensure_directory,
    ensure_directories,
    setup_session,
)


def test_setup_logger():
    """Test logger setup."""
    logger = setup_logger("test_logger")
    assert logger is not None
    assert logger.name == "test_logger"


def test_load_config():
    """Test configuration loading."""
    config = load_config("config/config.yaml")
    assert config is not None
    assert "paths" in config
    assert "sources" in config
    assert "bronze" in config["paths"]
    assert "silver" in config["paths"]
    assert "gold" in config["paths"]


def test_load_config_invalid_path():
    """Test configuration loading with invalid path."""
    with pytest.raises(FileNotFoundError):
        load_config("config/nonexistent.yaml")


def test_ensure_directory(tmp_path):
    """Test directory creation."""
    test_file = tmp_path / "test" / "file.txt"
    ensure_directory(test_file)
    assert test_file.parent.exists()


def test_ensure_directories(tmp_path):
    """Test multiple directory creation."""
    paths = {
        "bronze": str(tmp_path / "bronze"),
        "silver": str(tmp_path / "silver"),
        "gold": str(tmp_path / "gold"),
    }
    ensure_directories(paths)
    assert Path(paths["bronze"]).exists()
    assert Path(paths["silver"]).exists()
    assert Path(paths["gold"]).exists()


def test_setup_session():
    """Test session setup with retries."""
    session = setup_session()
    assert session is not None
    assert "User-Agent" in session.headers
    assert session.headers["User-Agent"] == "NYCCollisionETL/1.0"

