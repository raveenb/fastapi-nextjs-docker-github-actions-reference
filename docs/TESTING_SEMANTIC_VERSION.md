# Testing Semantic Versioning

## How the System Works

1. **On Pull Requests**: The `version-check.yml` workflow analyzes commits and predicts version bump
2. **On Merge to Main**: The `semantic-version.yml` workflow creates tags and releases

## Current Setup Status

✅ **Working Components:**
- Version prediction on PRs (see PR #85)
- Automatic release creation (v0.0.1 already created)
- Conventional commit validation
- Commit helper script

## Testing Scenarios

### 1. Test Version Prediction (PR Comment)
```bash
# Create a branch with different commit types
git checkout -b test/version-bump
echo "test" > test.txt
git add test.txt

# Test different commits:
git commit -m "fix: resolve critical bug"        # Predicts patch (0.0.1 -> 0.0.2)
git commit -m "feat: add new feature"           # Predicts minor (0.0.1 -> 0.1.0)
git commit -m "feat!: breaking API change"      # Predicts major (0.0.1 -> 1.0.0)

# Push and create PR
git push origin test/version-bump
gh pr create --title "test: version bumps" --body "Testing"
```

### 2. Test Actual Version Bump
When a PR is merged to main, the workflow will:
1. Analyze all commits since last tag
2. Determine version bump type
3. Create new tag (e.g., v0.0.2)
4. Generate GitHub release
5. Update version files

### 3. Test Manual Version Bump
```bash
# Trigger workflow manually via GitHub Actions
gh workflow run semantic-version.yml \
  -f bump_type=minor \
  -f prerelease_identifier=beta
```

### 4. Test Commit Helper Script
```bash
# Interactive commit creation
./scripts/commit-helper.sh

# Follow prompts to create conventional commits
```

## Verifying the System

### Check Current Version
```bash
# View releases
gh release list

# View tags
git tag -l

# Check latest tag
git describe --tags --abbrev=0
```

### Check PR Predictions
1. Create PR with conventional commits
2. Wait for bot comment (~30 seconds)
3. Comment shows predicted version

### Check Release Creation
1. Merge PR to main
2. Check Actions tab for workflow run
3. New release appears in Releases page

## Version Bump Rules

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `fix:` | Patch (0.0.X) | 0.0.1 → 0.0.2 |
| `feat:` | Minor (0.X.0) | 0.0.1 → 0.1.0 |
| `feat!:` or `BREAKING CHANGE:` | Major (X.0.0) | 0.0.1 → 1.0.0 |
| `docs:`, `chore:`, `test:` | No bump | 0.0.1 → 0.0.1 |

## Troubleshooting

### PR Comment Not Appearing
- Check workflow runs: `gh run list --workflow=version-check.yml`
- Ensure PR has conventional commits
- Wait 30-60 seconds for workflow to complete

### Release Not Created
- Check main branch protection rules
- Verify workflow permissions
- Check workflow runs: `gh run list --workflow=semantic-version.yml`

### Version Files Not Updated
The workflow updates:
- `VERSION` file (if exists)
- `src/fastapi/pyproject.toml`
- `src/nextjs/package.json`
- `docker-compose.yml`

## Current Version
- **Latest Release**: v0.0.1
- **Created**: Automatically by semantic version workflow
- **Next Version**: Will be determined by next merged PR