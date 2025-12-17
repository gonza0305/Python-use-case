#!/bin/bash
# Script to run all code quality checks locally
# Usage: ./scripts/check_code.sh

set -e  # Exit on error

echo "🔍 Running code quality checks..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}❌ Poetry is not installed. Please install it first.${NC}"
    exit 1
fi

# Install dependencies if needed
echo -e "${YELLOW}📦 Checking dependencies...${NC}"
poetry install --no-interaction

echo ""
echo -e "${YELLOW}1️⃣ Checking code formatting with Black...${NC}"
poetry run black --check src/ main.py || {
    echo -e "${RED}❌ Black check failed. Run 'poetry run black src/ main.py' to fix.${NC}"
    exit 1
}
echo -e "${GREEN}✅ Black check passed${NC}"

echo ""
echo -e "${YELLOW}2️⃣ Checking import sorting with isort...${NC}"
poetry run isort --check-only src/ main.py || {
    echo -e "${RED}❌ isort check failed. Run 'poetry run isort src/ main.py' to fix.${NC}"
    exit 1
}
echo -e "${GREEN}✅ isort check passed${NC}"

echo ""
echo -e "${YELLOW}3️⃣ Linting with flake8...${NC}"
poetry run flake8 src/ main.py --count --select=E9,F63,F7,F82 --show-source --statistics || {
    echo -e "${RED}❌ Flake8 critical errors found${NC}"
    exit 1
}
poetry run flake8 src/ main.py --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
echo -e "${GREEN}✅ Flake8 check passed${NC}"

echo ""
echo -e "${YELLOW}4️⃣ Type checking with mypy...${NC}"
poetry run mypy src/ --ignore-missing-imports || {
    echo -e "${YELLOW}⚠️  MyPy found some issues (non-blocking)${NC}"
}
echo -e "${GREEN}✅ MyPy check completed${NC}"

echo ""
echo -e "${YELLOW}5️⃣ Running unit tests...${NC}"
poetry run pytest tests/unit/ -v --cov=src --cov-report=term-missing || {
    echo -e "${RED}❌ Tests failed${NC}"
    exit 1
}
echo -e "${GREEN}✅ All tests passed${NC}"

echo ""
echo -e "${YELLOW}6️⃣ Security scan with bandit...${NC}"
poetry run bandit -r src/ -f json || {
    echo -e "${YELLOW}⚠️  Bandit found some issues (non-blocking)${NC}"
}
echo -e "${GREEN}✅ Security scan completed${NC}"

echo ""
echo -e "${YELLOW}7️⃣ Validating configuration...${NC}"
python -c "import yaml; yaml.safe_load(open('config/config.yaml'))" || {
    echo -e "${RED}❌ Config validation failed${NC}"
    exit 1
}
echo -e "${GREEN}✅ Config validation passed${NC}"

echo ""
echo -e "${GREEN}🎉 All checks passed! You're ready to commit.${NC}"

