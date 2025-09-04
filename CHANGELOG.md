# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Semantic versioning with automatic tagging
- Conventional commits support with validation
- Version prediction for pull requests
- Commit helper script for developers
- Contributing guidelines with commit conventions

## [0.1.0] - 2025-09-04

### Added
- Initial FastAPI backend with health endpoints and configuration management
- Next.js frontend with TypeScript and Tailwind CSS
- Docker containerization with multi-stage builds
- Docker Compose orchestration for local development
- PostgreSQL database with initialization scripts
- GitHub Actions CI/CD workflows
- Act support for local CI/CD testing
- Docker build and push workflows with multi-platform support
- Comprehensive test suites for backend and frontend
- Memory Bank system for project context tracking
- Project documentation (README, CLAUDE.md)

### Technical Stack
- **Backend**: FastAPI, Pydantic, uvicorn, loguru
- **Frontend**: Next.js 15, React 19, TypeScript, Tailwind CSS v4
- **Database**: PostgreSQL 16
- **Containerization**: Docker, Docker Compose
- **CI/CD**: GitHub Actions, Act
- **Testing**: pytest, Jest, Testing Library
- **Package Management**: uv (Python), pnpm (Node.js)

### Infrastructure
- Multi-stage Docker builds for optimized images
- GitHub Container Registry (ghcr.io) integration
- Security scanning with Trivy
- Health check endpoints for all services
- Environment-based configuration
- Feature flags system

[unreleased]: https://github.com/raveenb/fastapi-nextjs-docker-github-actions-reference/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/raveenb/fastapi-nextjs-docker-github-actions-reference/releases/tag/v0.1.0