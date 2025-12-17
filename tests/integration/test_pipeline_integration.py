"""Integration tests for the pipeline."""
import pytest
from pathlib import Path
import tempfile
import shutil


@pytest.mark.integration
@pytest.mark.slow
def test_config_file_exists():
    """Test that configuration file exists and is valid."""
    config_path = Path("config/config.yaml")
    assert config_path.exists(), "Config file should exist"
    
    from src.utils import load_config
    config = load_config()
    assert config is not None
    assert "paths" in config
    assert "sources" in config


@pytest.mark.integration
def test_data_directories_creation():
    """Test that data directories can be created."""
    with tempfile.TemporaryDirectory() as tmpdir:
        from src.utils import ensure_directories
        
        paths = {
            "bronze": str(Path(tmpdir) / "bronze"),
            "silver": str(Path(tmpdir) / "silver"),
            "gold": str(Path(tmpdir) / "gold"),
        }
        
        ensure_directories(paths)
        
        for path_str in paths.values():
            assert Path(path_str).exists()
            assert Path(path_str).is_dir()

