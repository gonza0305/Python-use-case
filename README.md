# NYC Collision ETL Pipeline

Complete ETL pipeline for analyzing NYC traffic collision data, implementing a medallion architecture (Bronze, Silver, Gold) with efficient processing using Polars and DuckDB.

## Description

This project processes and enriches NYC traffic collision data by combining it with holiday information and historical weather data. The pipeline is designed following data engineering best practices, with clear separation of responsibilities and optimized processing.

### Key Features

- **Medallion Architecture**: Implementation of Bronze (raw), Silver (transformed), and Gold (aggregated) layers
- **High Performance**: Uses Polars for fast data processing
- **Idempotent Processing**: Repeated executions don't duplicate data
- **Multiple Data Sources**: Integration of collision, holiday, and weather data
- **Robust Error Handling**: Automatic retries and detailed logging
- **Partitioned Storage**: Data organized by year/month for efficient queries

## Architecture

The pipeline follows a three-layer architecture:

### Bronze Layer (Ingestion)
- Downloads and stores raw data from external sources
- No transformations, preserves original data
- Format: CSV and JSON

### Silver Layer (Transformation)
- Data cleaning and standardization
- Column and data type normalization
- Partitioned by year/month
- Format: Partitioned Parquet

### Gold Layer (Aggregation)
- Enrichment with joins across multiple sources
- Daily-level aggregations
- Business rule application
- Format: Parquet and CSV for analysis

## Installation

### Prerequisites

- Python 3.11 or higher
- Poetry (recommended) or pip

### Installation with Poetry

**Installing Poetry on Windows:**

```powershell
# Method 1: Using the official installer (PowerShell)
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -

# Method 2: Using pip (alternative)
pip install poetry

# Method 3: Using pipx (recommended if you have pipx)
pipx install poetry
```

**After installation, add Poetry to PATH (if needed):**

Add `%APPDATA%\Python\Scripts` or `%LOCALAPPDATA%\pypoetry\Cache\pypoetry\venv\Scripts` to your PATH environment variable, or restart your terminal.

**Verify installation:**
```powershell
poetry --version
```

**Then install project dependencies:**
```bash
# Navigate to project directory
cd uptimal-use-case

# Install dependencies
poetry install

# Activate virtual environment
poetry shell
```

### Installation with pip

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

## Configuration

The project uses a YAML configuration file located at `config/config.yaml`. You can modify the following options:

```yaml
paths:
  bronze: "data/bronze"    # Path for raw data
  silver: "data/silver"    # Path for transformed data
  gold: "data/gold"        # Path for aggregated data

sources:
  collisions:
    url: "https://data.cityofnewyork.us/api/views/h9gi-nx95/rows.csv?accessType=DOWNLOAD"
    filename: "collisions_raw.csv"
  
  holidays:
    url_base: "https://date.nager.at/api/v3/publicholidays"
    country_code: "US"
    years: [2020, 2021, 2022, 2023, 2024, 2025]
    filename: "holidays_raw.json"
  
  weather:
    url: "https://www.ncei.noaa.gov/data/global-historical-climatology-network-daily/access/USW00094728.csv"
    filename: "weather_raw.csv"
```

### Environment Variables (Optional)

Create a `.env` file in the project root if you need to configure additional environment variables:

```env
# Example environment variables
ENVIRONMENT=dev
LOG_LEVEL=INFO
```

## Usage

### Basic Execution

```bash
python main.py
```

### Command Line Options

```bash
# Run in development mode (default)
python main.py --env dev

# Run in production mode
python main.py --env prod

# Enable verbose mode (DEBUG)
python main.py --verbose

# Combine options
python main.py --env prod --verbose
```

### Execution as Module

```bash
python -m src.pipeline
```

## Project Structure

```
uptimal-use-case/
├── config/
│   └── config.yaml              # Pipeline configuration
├── data/                        # Data directory (auto-generated)
│   ├── bronze/                  # Raw data
│   ├── silver/                  # Transformed data
│   └── gold/                    # Aggregated data
├── notebooks/
│   └── analysis.ipynb          # Analysis notebooks
├── src/
│   ├── layers/
│   │   ├── bronze_processing.py # Bronze Layer: Ingestion
│   │   ├── silver_processing.py # Silver Layer: Transformation
│   │   └── gold_processing.py   # Gold Layer: Aggregation
│   ├── pipeline.py              # Pipeline orchestration
│   └── utils.py                 # Shared utilities
├── tests/
│   ├── integration/             # Integration tests
│   └── unit/                    # Unit tests
├── main.py                      # Main entry point
├── pyproject.toml               # Poetry configuration
├── requirements.txt             # pip dependencies
└── README.md                    # This file
```

## Data Sources

### 1. NYC Traffic Collisions
- **Source**: NYC Open Data (Socrata API)
- **Format**: CSV
- **Content**: Detailed collision information including date, time, location, victims, contributing factors

### 2. Holidays
- **Source**: Nager.Date API
- **Format**: JSON
- **Content**: US public holidays with types and categories

### 3. Weather Data
- **Source**: NOAA GHCN-Daily (Central Park, NYC)
- **Format**: CSV
- **Content**: Maximum/minimum temperatures, precipitation, snow, weather events

## Technologies Used

- **Polars 1.35.2**: High-performance data processing
- **DuckDB 1.4.3**: Analytical database engine
- **PyArrow 22.0.0**: Parquet format support
- **Python 3.11+**: Programming language
- **Poetry**: Dependency management
- **PyYAML**: Configuration handling
- **Requests**: HTTP client with automatic retries

### Development Dependencies

- **Jupyter/IPython**: For analysis notebooks
- **Matplotlib/Seaborn**: Data visualization
- **Pandas**: Compatibility and additional analysis

## Pipeline Flow

1. **Phase 1: Bronze (Ingestion)**
   - Download collision data from NYC Open Data
   - Fetch holidays from Nager.Date API
   - Download weather data from NOAA
   - Store in original format

2. **Phase 2: Silver (Transformation)**
   - Clean and standardize collisions
   - Normalize holidays
   - Process weather data (unit conversion, event flags)
   - Partition by year/month
   - Persist to Parquet

3. **Phase 3: Gold (Aggregation)**
   - Join collisions with holidays and weather
   - Apply business rules (holiday impact flags, weather events)
   - Daily aggregation by borough, zip code, conditions
   - Generate final statistics
   - Export to Parquet and CSV

## Pipeline Output

### Gold Layer Output

The pipeline generates an aggregated dataset with the following daily metrics:

- `total_accidents`: Total number of accidents
- `number_of_persons_injured`: Injured persons
- `number_of_persons_killed`: Fatalities
- `number_of_pedestrians_injured/killed`: Pedestrian victims
- `number_of_cyclist_injured/killed`: Cyclist victims
- `number_of_motorist_injured/killed`: Motorist victims

Grouped by:
- Date, Borough, Zip Code
- Day of week (is_weekend)
- Holiday and impact type
- Weather conditions (rain, snow, fog)
- Maximum and minimum temperatures

## Testing

```bash
# Run unit tests
pytest tests/unit/

# Run integration tests
pytest tests/integration/

# Run all tests
pytest

# Run tests with coverage
pytest --cov=src --cov-report=html

# Run only fast tests (exclude slow/integration)
pytest -m "not slow and not integration"
```

## CI/CD

This project includes GitHub Actions workflows for continuous integration:

### Automated Checks on PRs

When you open a Pull Request, the following checks run automatically:

- **Code Formatting** (Black) - Ensures consistent code style
- **Linting** (Flake8) - Checks for code quality issues
- **Type Checking** (MyPy) - Validates type hints
- **Import Sorting** (isort) - Ensures imports are organized
- **Unit Tests** - Runs all unit tests with coverage
- **Security Scan** (Bandit & Safety) - Checks for security vulnerabilities
- **Configuration Validation** - Validates YAML config files

### Branch Protection

The repository is configured with branch protection rules that:
- Require all CI checks to pass before merging
- Require at least one code review
- Prevent force pushes to main branch

See [`.github/BRANCH_PROTECTION.md`](.github/BRANCH_PROTECTION.md) for setup instructions.

### Running Checks Locally

Before pushing, you can run the same checks locally:

**Quick check (recommended):**
```bash
# Linux/Mac
./scripts/check_code.sh

# Windows PowerShell
.\scripts\check_code.ps1
```

**Individual checks:**
```bash
# Format code
poetry run black src/ main.py

# Check formatting (without changing files)
poetry run black --check src/ main.py

# Lint code
poetry run flake8 src/ main.py

# Type check
poetry run mypy src/

# Sort imports
poetry run isort src/ main.py

# Check import sorting
poetry run isort --check-only src/ main.py

# Run security scan
poetry run bandit -r src/
poetry run safety check

# Run all tests
poetry run pytest
```

See [`.github/BRANCH_PROTECTION.md`](.github/BRANCH_PROTECTION.md) for instructions on setting up branch protection rules in GitHub.

## Logging

The pipeline includes detailed logging at each phase:

- **INFO**: General pipeline progress
- **DEBUG**: Processing details (enabled with `--verbose`)
- **ERROR**: Processing errors
- **CRITICAL**: Critical errors that stop the pipeline

Logs follow the format:
```
YYYY-MM-DD HH:MM:SS - <module> - <level> - <message>
```

## Development

### Code Structure

- **Separation of Concerns**: Each layer has its own processor class
- **Dependency Injection**: Configuration injected in constructors
- **Polymorphism**: Support for input from DataFrame or Path
- **Idempotency**: Repeated executions are safe

### Best Practices Implemented

- Robust error handling with automatic retries
- Structured logging
- External configuration (YAML)
- Type validation
- Code documentation
- Appropriate exit codes for orchestrators (Airflow, Jenkins)

## Troubleshooting

### Download Error

If the pipeline fails to download data:
- Check your internet connection
- Verify that URLs in `config.yaml` are accessible
- Downloaded files are cached, delete `data/bronze/` to force re-download

### Memory Errors

For very large datasets:
- Consider filtering by date range in configuration
- Increase available memory
- Process in smaller batches

### Partition Issues

If there are errors writing partitions:
- Check write permissions on `data/`
- Ensure you have sufficient disk space

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome. Please:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Contact

For questions or suggestions, please open an issue in the repository.

---

**Note**: This pipeline is designed to process historical NYC data. Make sure to comply with the terms of use of the APIs and data sources used.
