#!/bin/bash

# Docker build script for Next.js frontend
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="nextjs-frontend"
IMAGE_TAG="${1:-latest}"
DOCKERFILE="${2:-Dockerfile}"
BUILD_CONTEXT="."

# Build arguments
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
VERSION=$(node -p "require('./package.json').version" 2>/dev/null || echo "0.1.0")

echo -e "${GREEN}Building Next.js Docker image...${NC}"
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Dockerfile: ${DOCKERFILE}"
echo "Build Date: ${BUILD_DATE}"
echo "Git Ref: ${VCS_REF}"
echo "Version: ${VERSION}"
echo ""

# Build the Docker image
docker build \
  --build-arg BUILD_DATE="${BUILD_DATE}" \
  --build-arg VCS_REF="${VCS_REF}" \
  --build-arg VERSION="${VERSION}" \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
  --tag "${IMAGE_NAME}:${VCS_REF}" \
  --file "${DOCKERFILE}" \
  "${BUILD_CONTEXT}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker image built successfully!${NC}"
    echo ""
    echo "Tagged as:"
    echo "  - ${IMAGE_NAME}:${IMAGE_TAG}"
    echo "  - ${IMAGE_NAME}:${VCS_REF}"
    echo ""
    echo "To run the container:"
    echo "  docker run -p 3000:3000 ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    echo "To run with environment file:"
    echo "  docker run -p 3000:3000 --env-file .env ${IMAGE_NAME}:${IMAGE_TAG}"
    echo ""
    echo "To run in development mode:"
    echo "  docker run -p 3000:3000 -v \$(pwd):/app ${IMAGE_NAME}:dev"
else
    echo -e "${RED}✗ Docker build failed!${NC}"
    exit 1
fi