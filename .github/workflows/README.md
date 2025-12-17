# GitHub Actions Workflows

This directory contains CI/CD workflows for the project.

## Workflows

### `ci.yml` - Continuous Integration

This workflow runs on every pull request and push to main branches. It includes:

#### Jobs

1. **lint-and-test** (runs on Python 3.11 and 3.12)
   - Code formatting check (Black)
   - Linting (Flake8)
   - Type checking (MyPy)
   - Unit tests with coverage
   - Import sorting check (isort)

2. **security-scan**
   - Security vulnerability scanning (Bandit)
   - Dependency security check (Safety)

3. **validate-config**
   - YAML configuration validation
   - Config file existence check

#### Requirements

All jobs must pass for a PR to be mergeable (when branch protection is enabled).

## Setting Up Branch Protection

To require these checks before merging:

1. Go to repository Settings → Branches
2. Add a branch protection rule for `main` (or `master`)
3. Enable "Require status checks to pass before merging"
4. Select all jobs from the `lint-and-test`, `security-scan`, and `validate-config` workflows
5. Save the rule

See [BRANCH_PROTECTION.md](../BRANCH_PROTECTION.md) for detailed instructions.

## Local Testing

You can run the same checks locally using:

```bash
# Linux/Mac
./scripts/check_code.sh

# Windows PowerShell
.\scripts\check_code.ps1
```

Or run individual checks as documented in the main README.

