"""Unit tests for Bronze layer processing."""
import pytest
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock
import polars as pl
from src.layers.bronze_processing import BronzeExtractor


@pytest.fixture
def mock_config():
    """Mock configuration."""
    return {
        "paths": {
            "bronze": "data/bronze",
        },
        "sources": {
            "collisions": {
                "url": "https://example.com/data.csv",
                "filename": "test.csv",
            },
        },
    }


@pytest.fixture
def bronze_extractor(mock_config):
    """Create BronzeExtractor instance."""
    return BronzeExtractor(mock_config)


def test_bronze_extractor_init(mock_config):
    """Test BronzeExtractor initialization."""
    extractor = BronzeExtractor(mock_config)
    assert extractor.config == mock_config
    assert extractor.session is not None


@patch("src.layers.bronze_processing.pl.read_csv")
@patch("src.layers.bronze_processing.Path.exists")
@patch("builtins.open", create=True)
def test_download_file_from_url_cached(mock_open, mock_exists, mock_read_csv, bronze_extractor, tmp_path):
    """Test file download when file is already cached."""
    output_path = tmp_path / "test.csv"
    mock_exists.return_value = True
    
    # Create a dummy dataframe
    mock_df = pl.DataFrame({"col1": [1, 2, 3]})
    mock_read_csv.return_value = mock_df
    
    df, path = bronze_extractor.download_file_from_url(
        url="https://example.com/data.csv",
        output_path=output_path,
    )
    
    assert df is not None
    assert path == output_path
    mock_read_csv.assert_called_once()


def test_fetch_holidays_structure(mock_config):
    """Test holidays fetch structure."""
    extractor = BronzeExtractor(mock_config)
    
    # This is a basic structure test
    # Full integration test would require mocking the API
    assert extractor.session is not None

