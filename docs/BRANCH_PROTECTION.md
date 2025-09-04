# Branch Protection Guide

## Overview

Branch protection rules ensure code quality and prevent accidental damage to important branches. This guide explains our branch protection setup for the `main` branch.

## Protection Rules

### 🔒 Main Branch Protection

The following rules are configured for the `main` branch:

#### 1. **Require Pull Request Reviews**
- ✅ At least 1 approval required
- ✅ Dismiss stale reviews when new commits are pushed
- ✅ Require conversation resolution before merging

#### 2. **Require Status Checks**
All CI checks must pass before merging:
- `test-backend` - Backend tests must pass
- `test-frontend` - Frontend tests must pass
- `lint` - Code linting must pass
- `type-check` - Type checking must pass
- `build-backend` - Backend must build successfully
- `build-frontend` - Frontend must build successfully

#### 3. **Require Up-to-Date Branches**
- ✅ Branches must be up to date with main before merging
- Prevents merge conflicts and ensures tests run on latest code

#### 4. **Restrict Direct Commits**
- ❌ No direct commits to main
- ❌ No force pushes allowed
- ❌ No branch deletions allowed
- All changes must go through pull requests

## Setup Instructions

### Option 1: Using the Setup Script (Recommended)

```bash
# Run the interactive setup script
./scripts/setup-branch-protection.sh

# Choose option 1 to apply recommended rules
```

### Option 2: Using GitHub UI

1. Go to **Settings** → **Branches**
2. Click **Add rule** or edit existing rule for `main`
3. Configure the following:

   **Branch name pattern**: `main`
   
   **Protect matching branches**:
   - ✅ Require a pull request before merging
     - ✅ Require approvals: 1
     - ✅ Dismiss stale pull request approvals
     - ✅ Require conversation resolution
   
   - ✅ Require status checks to pass
     - ✅ Require branches to be up to date
     - Add these status checks:
       - test-backend
       - test-frontend
       - lint
       - type-check
       - build-backend
       - build-frontend
   
   - ✅ Do not allow bypassing the above settings
   - ✅ Restrict who can push to matching branches (optional)

### Option 3: Using GitHub CLI

```bash
# Quick setup with gh CLI
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/OWNER/REPO/branches/main/protection \
  --field required_status_checks='{"strict":true,"contexts":["test-backend","test-frontend","lint","type-check"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

### Option 4: Using GitHub Actions Workflow

```bash
# Trigger the workflow manually
gh workflow run branch-protection.yml
```

## Checking Protection Status

### Using the Script
```bash
./scripts/setup-branch-protection.sh
# Choose option 2 to view status
```

### Using GitHub CLI
```bash
gh api /repos/OWNER/REPO/branches/main/protection
```

### Using GitHub UI
Go to **Settings** → **Branches** → View rules for `main`

## Working with Protected Branches

### For Contributors

1. **Create a feature branch**:
   ```bash
   git checkout -b feat/your-feature
   ```

2. **Make your changes and commit**:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. **Push to GitHub**:
   ```bash
   git push origin feat/your-feature
   ```

4. **Create a Pull Request**:
   ```bash
   gh pr create
   ```

5. **Wait for**:
   - CI checks to pass
   - Code review approval
   - Conversations to be resolved

6. **Merge** (or have a maintainer merge)

### For Maintainers

- Review PRs promptly
- Ensure CI checks are passing
- Verify conversations are resolved
- Use squash and merge for clean history

## Bypassing Protection (Emergency Only)

If you need to temporarily disable protection:

```bash
# Remove protection (DANGEROUS!)
gh api \
  --method DELETE \
  /repos/OWNER/REPO/branches/main/protection

# Make emergency fix
git push origin main

# Re-enable protection immediately
./scripts/setup-branch-protection.sh
```

⚠️ **WARNING**: Only do this in emergencies. Always re-enable protection immediately.

## Troubleshooting

### "Branch protection rules not met"
- Ensure all CI checks are passing
- Get required approvals
- Update branch with latest main: `git pull origin main`
- Resolve all conversations

### "Required status checks not found"
- Status checks are created after first CI run
- Create a test PR to initialize status checks
- Then re-apply protection rules

### "Waiting for status checks"
- Check Actions tab for running workflows
- Ensure workflows are not stuck
- Restart failed checks if needed

## Benefits

✅ **Code Quality**: All code is tested and reviewed
✅ **Stability**: Main branch always works
✅ **Audit Trail**: All changes tracked through PRs
✅ **Collaboration**: Team reviews improve code
✅ **Automation**: CI/CD runs on every change
✅ **Versioning**: Semantic versioning tracks all changes

## Related Documentation

- [Contributing Guide](../CONTRIBUTING.md)
- [CI/CD Workflows](.github/workflows/README.md)
- [Semantic Versioning](./TESTING_SEMANTIC_VERSION.md)