# PowerShell script to run all code quality checks locally
# Usage: .\scripts\check_code.ps1

$ErrorActionPreference = "Stop"

Write-Host "🔍 Running code quality checks..." -ForegroundColor Yellow
Write-Host ""

# Check if poetry is installed
if (-not (Get-Command poetry -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Poetry is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Install dependencies if needed
Write-Host "📦 Checking dependencies..." -ForegroundColor Yellow
poetry install --no-interaction

Write-Host ""
Write-Host "1️⃣ Checking code formatting with Black..." -ForegroundColor Yellow
poetry run black --check src/ main.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Black check failed. Run 'poetry run black src/ main.py' to fix." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Black check passed" -ForegroundColor Green

Write-Host ""
Write-Host "2️⃣ Checking import sorting with isort..." -ForegroundColor Yellow
poetry run isort --check-only src/ main.py
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ isort check failed. Run 'poetry run isort src/ main.py' to fix." -ForegroundColor Red
    exit 1
}
Write-Host "✅ isort check passed" -ForegroundColor Green

Write-Host ""
Write-Host "3️⃣ Linting with flake8..." -ForegroundColor Yellow
poetry run flake8 src/ main.py --count --select=E9,F63,F7,F82 --show-source --statistics
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flake8 critical errors found" -ForegroundColor Red
    exit 1
}
poetry run flake8 src/ main.py --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
Write-Host "✅ Flake8 check passed" -ForegroundColor Green

Write-Host ""
Write-Host "4️⃣ Type checking with mypy..." -ForegroundColor Yellow
poetry run mypy src/ --ignore-missing-imports
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  MyPy found some issues (non-blocking)" -ForegroundColor Yellow
}
Write-Host "✅ MyPy check completed" -ForegroundColor Green

Write-Host ""
Write-Host "5️⃣ Running unit tests..." -ForegroundColor Yellow
poetry run pytest tests/unit/ -v --cov=src --cov-report=term-missing
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Tests failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ All tests passed" -ForegroundColor Green

Write-Host ""
Write-Host "6️⃣ Security scan with bandit..." -ForegroundColor Yellow
poetry run bandit -r src/ -f json
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Bandit found some issues (non-blocking)" -ForegroundColor Yellow
}
Write-Host "✅ Security scan completed" -ForegroundColor Green

Write-Host ""
Write-Host "7️⃣ Validating configuration..." -ForegroundColor Yellow
python -c "import yaml; yaml.safe_load(open('config/config.yaml'))"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Config validation failed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Config validation passed" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 All checks passed! You're ready to commit." -ForegroundColor Green

