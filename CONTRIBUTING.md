# Contributing to FastAPI-Next.js Reference

Thank you for considering contributing to this reference implementation! This document provides guidelines and instructions for contributing.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code:
- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

1. **Fork the repository** and clone your fork:
   ```bash
   git clone https://github.com/your-username/fastapi-nextjs-reference.git
   cd fastapi-nextjs-reference
   ```

2. **Set up the development environment**:
   ```bash
   # Backend setup
   cd src/fastapi
   uv venv
   uv pip install -e ".[dev]"
   
   # Frontend setup
   cd ../nextjs
   pnpm install
   ```

3. **Create a new branch** for your feature or fix:
   ```bash
   git checkout -b feat/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

## Development Workflow

1. **Make your changes** following the project's coding standards
2. **Run code quality checks**:
   ```bash
   # Python (backend)
   black .
   ruff check . --fix
   mypy .
   
   # TypeScript (frontend)
   prettier --write .
   eslint . --fix
   tsc --noEmit
   ```

3. **Run tests** to ensure nothing is broken:
   ```bash
   # Backend tests
   cd src/fastapi && uv run pytest
   
   # Frontend tests
   cd src/nextjs && pnpm test
   ```

4. **Commit your changes** using conventional commits (see below)

## Commit Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/) for automatic versioning and changelog generation.

### Commit Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: A new feature (triggers MINOR version bump)
- **fix**: A bug fix (triggers PATCH version bump)
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, etc)
- **refactor**: Code refactoring without feature/fix
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Build system or dependency changes
- **ci**: CI/CD configuration changes
- **chore**: Other changes (maintenance)
- **revert**: Revert a previous commit

### Breaking Changes
Add `!` after the type for breaking changes, or include `BREAKING CHANGE:` in the footer:
```
feat!: remove deprecated API endpoint

BREAKING CHANGE: The /api/v1/old endpoint has been removed
```

### Examples
```bash
# Feature
feat(api): add user authentication endpoint

# Bug fix
fix(frontend): resolve navigation menu overflow issue

# Breaking change
feat(database)!: migrate from PostgreSQL to MongoDB

BREAKING CHANGE: Database schema has been completely redesigned
```

### Using the Commit Helper
We provide a script to help create conventional commits:
```bash
./scripts/commit-helper.sh
```

## Pull Request Process

1. **Ensure your PR**:
   - Has a clear, descriptive title
   - References any related issues
   - Includes tests for new functionality
   - Passes all CI checks
   - Has updated documentation if needed

2. **PR Title Format**:
   Follow the same convention as commits:
   ```
   feat: add user authentication
   fix: resolve memory leak in worker process
   ```

3. **PR Description Template**:
   ```markdown
   ## Summary
   Brief description of the changes
   
   ## Changes
   - List of specific changes
   - Another change
   
   ## Testing
   - How to test the changes
   - Test scenarios covered
   
   ## Related Issues
   Closes #123
   Refs #456
   ```

4. **Review Process**:
   - PRs require at least one review
   - Address feedback constructively
   - Keep PRs focused and manageable

## Testing

### Running Tests
```bash
# All tests
make test

# Backend only
cd src/fastapi && uv run pytest -v

# Frontend only
cd src/nextjs && pnpm test

# E2E tests
pnpm test:e2e

# With coverage
uv run pytest --cov
pnpm test -- --coverage
```

### Writing Tests
- Write tests for all new features
- Maintain minimum 80% code coverage
- Follow existing test patterns
- Use meaningful test names

## Documentation

### Code Documentation
- Add docstrings to all public functions/classes (Python)
- Add JSDoc comments for exported functions (TypeScript)
- Include usage examples where helpful

### Project Documentation
- Update README.md for significant changes
- Update CLAUDE.md for AI-assisted development guidance
- Add ADRs (Architecture Decision Records) for major decisions

## Version Bumping

Version bumps are automatic based on commit types:
- **feat**: Minor version (0.X.0)
- **fix**: Patch version (0.0.X)
- **feat!** or **BREAKING CHANGE**: Major version (X.0.0)

## Local Development Tips

### Using Act for CI Testing
```bash
# Test CI workflows locally
act -j test
act -j build
```

### Docker Development
```bash
# Build and run with docker-compose
docker-compose up --build

# Run specific service
docker-compose up backend
```

### Hot Reload
Both backend and frontend support hot reload in development:
```bash
# Backend
cd src/fastapi && uv run dev

# Frontend
cd src/nextjs && pnpm dev
```

## Getting Help

- Check existing [issues](https://github.com/raveenb/fastapi-nextjs-docker-github-actions-reference/issues)
- Read the [documentation](./docs)
- Ask in discussions
- Contact maintainers

## Recognition

Contributors will be recognized in:
- The project README
- Release notes
- GitHub contributors page

Thank you for contributing! 🎉