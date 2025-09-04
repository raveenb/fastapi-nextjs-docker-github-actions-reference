# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL RULES (HIGH PRIORITY)

### Documentation Requirements
**MANDATORY**: You MUST use the context7 MCP server to fetch documentation for any package/library you are working with. This ensures version-specific accuracy.

1. **Always check package versions** from:
   - Python: `pyproject.toml`, `requirements.txt`, `uv.lock`
   - JavaScript/TypeScript: `package.json`, `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`
   - Other: Language-specific lock files

2. **Use context7 workflow**:
   - First: Call `mcp__context7__resolve-library-id` with the package name
   - Then: Call `mcp__context7__get-library-docs` with the resolved ID and version
   - This ensures you're using documentation matching the exact version in use

3. **Never assume** API compatibility across versions - always verify with version-specific docs

### Code Quality Requirements
**MANDATORY**: You MUST use these tools for all code changes. Run them before committing.

**Python Projects:**
1. **Formatting**: `black .` - MUST format all Python code with Black
2. **Linting**: `ruff check . --fix` - MUST use Ruff with autofix enabled
3. **Type Checking**: `mypy .` - MUST pass mypy static type checking

**Node.js/TypeScript Projects:**
1. **Formatting**: `prettier --write .` - MUST format all code with Prettier
2. **Linting**: `eslint . --fix` - MUST use ESLint with autofix enabled
3. **Type Checking**: `tsc --noEmit` - MUST pass TypeScript compiler checks

**Workflow:**
- Format first (black/prettier)
- Then lint with fixes (ruff/eslint)
- Finally type check (mypy/tsc)
- Only commit if all checks pass

### Code Quality Requirements
**MANDATORY**: You MUST use these tools for all code changes. Run them before committing.

**Python Projects:**
1. **Formatting**: `black .` - MUST format all Python code with Black
2. **Linting**: `ruff check . --fix` - MUST use Ruff with autofix enabled
3. **Type Checking**: `mypy .` - MUST pass mypy static type checking

**JavaScript/TypeScript Projects:**
1. **Formatting**: `prettier --write .` - MUST format all code with Prettier
2. **Linting**: `eslint . --fix` - MUST use ESLint with autofix enabled
3. **Type Checking**: `tsc --noEmit` - MUST pass TypeScript compiler checks

**Workflow:**
- Format first (black/prettier)
- Then lint with fixes (ruff/eslint)
- Finally type check (mypy/tsc)
- Only commit if all checks pass

## Project Overview

This is a reference implementation demonstrating best practices for building, testing, and deploying a modern full-stack application using:
- **Backend**: FastAPI with Pydantic for validation
- **Frontend**: Next.js with Zod for validation
- **Infrastructure**: Docker Swarm/Kubernetes with Terraform (AWS, GCP, OVH, Digital Ocean)
- **CI/CD**: GitHub Actions with Act for local testing
- **Developer Experience**: Claude Code with MCP servers

## Development Setup

### Prerequisites
- `uv` for Python package management
- `pnpm` for Node.js package management
- `docker` and `docker-compose` for containerization
- `act` for local CI/CD testing
- `terraform` for infrastructure provisioning

### Quick Start Commands
```bash
# Backend setup
cd src/fastapi
uv venv
uv pip install -e ".[dev]"
uv run pytest

# Frontend setup
cd src/nextjs
pnpm install
pnpm dev
pnpm test

# Docker development
docker-compose up --build

# Local CI/CD testing
act -j build
act -j test
```

## Project Structure

```
├── src/                    # All source code
│   ├── fastapi/           # FastAPI backend application
│   │   ├── app/          # Application code
│   │   ├── tests/        # pytest tests
│   │   └── pyproject.toml # uv/Python configuration
│   └── nextjs/            # Next.js frontend application
│       ├── src/          # Application code
│       ├── tests/        # Jest/Cypress tests
│       └── package.json  # pnpm configuration
├── infrastructure/        # Terraform configurations
│   ├── aws/              # AWS infrastructure
│   ├── gcp/              # GCP infrastructure
│   ├── ovh/              # OVH infrastructure
│   └── digital-ocean/    # Digital Ocean infrastructure
├── docker/               # Docker configurations
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── docker-compose.yml
├── .github/
│   ├── workflows/        # GitHub Actions workflows
│   └── ISSUE_TEMPLATE/   # Issue templates
├── .memory-bank/         # Project context and decisions
├── docs/                 # Additional documentation
└── scripts/              # Utility scripts
```

## Technology Stack

### Core Technologies
- **Backend**: FastAPI (Python) with uv package management
- **Frontend**: Next.js (TypeScript) with pnpm package management
- **Validation**: Pydantic (backend), Zod (frontend)
- **API**: REST endpoints and Server-Sent Events (SSE) for streaming

### Testing
- **Backend**: pytest with coverage
- **Frontend**: Jest (unit), Cypress (E2E)
- **CI/CD**: Act for local testing, GitHub Actions for hosted

### Infrastructure & Deployment
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Docker Swarm / Kubernetes
- **Load Balancing**: Traefik
- **IaC**: Terraform for AWS, GCP, OVH, Digital Ocean

### Observability & Monitoring
- **Logging**: Loguru (Python), Pino (Node.js)
- **Tracing**: OpenTelemetry (OTEL)
- **Metrics**: Prometheus-compatible

### Development Workflow
- **Version Control**: Git with Semantic Versioning (semver3)
- **Secret Management**: GitHub Secrets
- **Issue Tracking**: GitHub Issues
- **PR Process**: Protected branches, review requirements
- **Developer Tools**: Claude Code with MCP servers

## Commands

### Backend (FastAPI)
```bash
cd src/fastapi
uv run dev              # Start development server
uv run test            # Run pytest suite
uv run lint            # Run ruff linter
uv run format          # Format with black
uv run type-check      # Run mypy
uv run coverage        # Generate coverage report
```

### Frontend (Next.js)
```bash
cd src/nextjs
pnpm dev              # Start development server
pnpm build            # Build for production
pnpm test             # Run Jest tests
pnpm test:e2e         # Run Cypress tests
pnpm lint             # Run ESLint
pnpm format           # Format with Prettier
pnpm type-check       # Run TypeScript compiler
```

### Docker & Deployment
```bash
docker-compose up               # Start all services
docker-compose build           # Build images
docker stack deploy            # Deploy to Swarm
kubectl apply -f k8s/          # Deploy to Kubernetes
```

### Infrastructure (Terraform)
```bash
terraform init                 # Initialize providers
terraform plan                # Preview changes
terraform apply              # Apply infrastructure
terraform destroy            # Tear down infrastructure
```

### CI/CD
```bash
act -j build                  # Test build workflow locally
act -j test                   # Test testing workflow locally
act -j deploy                 # Test deployment workflow locally
```

## Memory Bank System

This project uses a Memory Bank system for tracking project context and progress:
- `active-context.md`: Current tasks and issues
- `product-context.md`: Product requirements and implementation details  
- `progress.md`: Completed work and next steps
- `decision-log.md`: Technical decisions and rationale
- `system-patterns.md`: Code patterns and conventions

## Development Modes

The project supports multiple development modes via `.clinerules-*` files:
- **Architect Mode**: System design and documentation
- **Code Mode**: Implementation and feature development
- **Debug Mode**: Troubleshooting and performance optimization
- **Test Mode**: Test creation and validation
- **Ask Mode**: Documentation and knowledge sharing

## Best Practices

1. **API Design**: RESTful endpoints with OpenAPI documentation
2. **Validation**: Schema validation at API boundaries (Pydantic/Zod)
3. **Testing**: Minimum 80% code coverage
4. **Security**: Environment-based secrets, HTTPS only
5. **Logging**: Structured JSON logging with correlation IDs
6. **Versioning**: Semantic versioning with automated releases
7. **Documentation**: Inline code docs + comprehensive README files
8. **Performance**: Caching, async operations, connection pooling

## MCP Server Integration

Claude Code is configured with MCP servers for enhanced development:
- File system operations
- Database interactions
- API testing
- Documentation generation

## GitHub Workflows

- **PR Process**: Auto-testing, linting, type-checking
- **CI/CD Pipeline**: Build → Test → Deploy
- **Release Process**: Semantic versioning with changelog generation
- **Issue Templates**: Bug reports, feature requests, documentation