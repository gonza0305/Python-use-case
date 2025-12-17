# Branch Protection Setup Guide

This guide explains how to configure branch protection rules in GitHub to ensure that PRs cannot be merged until all CI checks pass.

## Setting Up Branch Protection

### Step 1: Navigate to Repository Settings

1. Go to your GitHub repository
2. Click on **Settings** (top menu)
3. Click on **Branches** (left sidebar)

### Step 2: Add Branch Protection Rule

1. Click **Add rule** or **Add branch protection rule**
2. In the **Branch name pattern** field, enter:
   - `main` (or `master` if that's your default branch)
   - Optionally add `develop` if you use a develop branch

### Step 3: Configure Protection Rules

Enable the following settings:

#### Required Checks

✅ **Require a pull request before merging**
   - ✅ Require approvals: 1 (or more as needed)
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require review from Code Owners (if you have a CODEOWNERS file)

✅ **Require status checks to pass before merging**
   - ✅ Require branches to be up to date before merging
   - In the search box, select:
     - `lint-and-test (3.11)` - Lint and Test job for Python 3.11
     - `lint-and-test (3.12)` - Lint and Test job for Python 3.12
     - `security-scan` - Security Scan job
     - `validate-config` - Validate Configuration job

✅ **Require conversation resolution before merging** (optional but recommended)

✅ **Require signed commits** (optional, for enhanced security)

#### Additional Options (Recommended)

✅ **Do not allow bypassing the above settings**
   - This prevents even admins from merging without checks

✅ **Include administrators** 
   - Ensures even admins follow the rules

✅ **Restrict who can push to matching branches**
   - Only allow specific teams/people to push directly

### Step 4: Save the Rule

Click **Create** or **Save changes** to apply the branch protection rule.

## What This Achieves

Once configured, the branch protection will:

1. **Block merges** if any CI check fails
2. **Require PR reviews** before merging
3. **Ensure code quality** by enforcing linting and tests
4. **Maintain security** by running security scans
5. **Validate configuration** to prevent broken deployments

## Testing the Setup

To verify the setup works:

1. Create a new branch with intentionally broken code (e.g., syntax error)
2. Open a PR to `main`
3. Verify that the PR shows ❌ failing checks
4. Try to merge - it should be blocked
5. Fix the code and push again
6. Once all checks pass ✅, the merge should be allowed

## Troubleshooting

### Checks Not Showing Up

If the required checks don't appear in the list:
- Make sure the workflow has run at least once on the branch
- Check that the workflow file is in `.github/workflows/`
- Verify the workflow syntax is correct

### Allow Specific Users to Bypass

If you need to allow certain users to bypass (not recommended):
- Uncheck "Do not allow bypassing the above settings"
- Add users to the bypass list (requires GitHub Enterprise)

## Additional Resources

- [GitHub Docs: About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Docs: Requiring status checks](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule#require-status-checks-before-merging)

