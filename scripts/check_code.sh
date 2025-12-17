#!/bin/bash
# Script to run all code quality checks locally
# Usage: ./scripts/check_code.sh

set -e  # Exit on error

echo "Running code quality checks..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}[ERROR] Poetry is not installed. Please install it first.${NC}"
    exit 1
fi

# Install dependencies if needed
echo -e "${YELLOW}[INFO] Checking dependencies...${NC}"
poetry install --no-interaction

echo ""
echo -e "${YELLOW}[1/7] Checking code formatting with Black...${NC}"
poetry run black --check src/ main.py || {
    echo -e "${RED}[ERROR] Black check failed. Run 'poetry run black src/ main.py' to fix.${NC}"
    exit 1
}
echo -e "${GREEN}[OK] Black check passed${NC}"

echo ""
echo -e "${YELLOW}[2/7] Checking import sorting with isort...${NC}"
poetry run isort --check-only src/ main.py || {
    echo -e "${RED}[ERROR] isort check failed. Run 'poetry run isort src/ main.py' to fix.${NC}"
    exit 1
}
echo -e "${GREEN}[OK] isort check passed${NC}"

echo ""
echo -e "${YELLOW}[3/7] Linting with flake8...${NC}"
poetry run flake8 src/ main.py --count --select=E9,F63,F7,F82 --show-source --statistics || {
    echo -e "${RED}[ERROR] Flake8 critical errors found${NC}"
    exit 1
}
poetry run flake8 src/ main.py --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
echo -e "${GREEN}[OK] Flake8 check passed${NC}"

echo ""
echo -e "${YELLOW}[4/7] Type checking with mypy...${NC}"
poetry run mypy src/ --ignore-missing-imports || {
    echo -e "${YELLOW}[WARNING] MyPy found some issues (non-blocking)${NC}"
}
echo -e "${GREEN}[OK] MyPy check completed${NC}"

echo ""
echo -e "${YELLOW}[5/7] Running unit tests...${NC}"
poetry run pytest tests/unit/ -v --cov=src --cov-report=term-missing || {
    echo -e "${RED}[ERROR] Tests failed${NC}"
    exit 1
}
echo -e "${GREEN}[OK] All tests passed${NC}"

echo ""
echo -e "${YELLOW}[6/7] Security scan with bandit...${NC}"
poetry run bandit -r src/ -f json || {
    echo -e "${YELLOW}[WARNING] Bandit found some issues (non-blocking)${NC}"
}
echo -e "${GREEN}[OK] Security scan completed${NC}"

echo ""
echo -e "${YELLOW}[7/7] Validating configuration...${NC}"
python -c "import yaml; yaml.safe_load(open('config/config.yaml'))" || {
    echo -e "${RED}[ERROR] Config validation failed${NC}"
    exit 1
}
echo -e "${GREEN}[OK] Config validation passed${NC}"

echo ""
echo -e "${GREEN}[SUCCESS] All checks passed! You're ready to commit.${NC}"

