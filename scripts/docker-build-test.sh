#!/bin/bash

# Docker Build Testing Script
# Tests Docker image builds locally before pushing to CI/CD

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/src/fastapi"
FRONTEND_DIR="$PROJECT_ROOT/src/nextjs"

# Parse arguments
BUILD_TYPE=${1:-"production"}
RUN_TESTS=${2:-"true"}
PUSH_TO_REGISTRY=${3:-"false"}
REGISTRY=${4:-"ghcr.io"}

echo -e "${BLUE}Docker Build Test Script${NC}"
echo "================================"
echo "Build Type: $BUILD_TYPE"
echo "Run Tests: $RUN_TESTS"
echo "Push to Registry: $PUSH_TO_REGISTRY"
echo "Registry: $REGISTRY"
echo ""

# Function to build Docker image
build_image() {
    local name=$1
    local context=$2
    local dockerfile=$3
    local tag=$4
    
    echo -e "${YELLOW}Building $name image...${NC}"
    
    if [ "$BUILD_TYPE" == "development" ]; then
        docker build \
            --file "$dockerfile" \
            --target development \
            --tag "$tag" \
            --build-arg BUILD_MODE=development \
            --build-arg ENABLE_HOT_RELOAD=true \
            "$context"
    else
        docker build \
            --file "$dockerfile" \
            --tag "$tag" \
            --build-arg BUILD_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
            --build-arg VCS_REF="$(git rev-parse --short HEAD)" \
            --build-arg VERSION="$(git describe --tags --always)" \
            "$context"
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $name image built successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to build $name image${NC}"
        return 1
    fi
}

# Function to test Docker image
test_image() {
    local name=$1
    local image=$2
    local port=$3
    local health_endpoint=$4
    
    echo -e "${YELLOW}Testing $name image...${NC}"
    
    # Run container
    container_id=$(docker run -d \
        --name "test-$name-$$" \
        -p "$port:$port" \
        "$image")
    
    # Wait for container to be ready
    echo "Waiting for container to be ready..."
    sleep 5
    
    # Check health endpoint
    if curl -f "http://localhost:$port$health_endpoint" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $name health check passed${NC}"
        result=0
    else
        echo -e "${RED}✗ $name health check failed${NC}"
        result=1
    fi
    
    # Get logs
    echo "Container logs:"
    docker logs "$container_id" | tail -20
    
    # Cleanup
    docker stop "$container_id" > /dev/null 2>&1
    docker rm "$container_id" > /dev/null 2>&1
    
    return $result
}

# Function to scan image for vulnerabilities
scan_image() {
    local name=$1
    local image=$2
    
    echo -e "${YELLOW}Scanning $name image for vulnerabilities...${NC}"
    
    if command -v trivy &> /dev/null; then
        trivy image --severity HIGH,CRITICAL "$image"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ No critical vulnerabilities found${NC}"
        else
            echo -e "${YELLOW}⚠ Vulnerabilities found (see above)${NC}"
        fi
    else
        echo -e "${YELLOW}Trivy not installed, skipping vulnerability scan${NC}"
        echo "Install with: brew install trivy (macOS) or check https://github.com/aquasecurity/trivy"
    fi
}

# Function to analyze image size
analyze_image() {
    local name=$1
    local image=$2
    
    echo -e "${YELLOW}Analyzing $name image...${NC}"
    
    # Get image size
    size=$(docker images "$image" --format "{{.Size}}")
    echo "Image size: $size"
    
    # Show image layers
    echo "Image layers:"
    docker history "$image" --no-trunc --format "table {{.CreatedBy}}\t{{.Size}}" | head -10
    
    # Analyze with dive if available
    if command -v dive &> /dev/null; then
        echo "Running dive analysis..."
        CI=true dive "$image" --ci-config .dive-ci.yml || true
    else
        echo -e "${YELLOW}Dive not installed, skipping detailed analysis${NC}"
        echo "Install with: brew install dive (macOS) or check https://github.com/wagoodman/dive"
    fi
}

# Main execution
main() {
    local backend_tag="backend:test-$(date +%s)"
    local frontend_tag="frontend:test-$(date +%s)"
    local exit_code=0
    
    # Determine Dockerfile to use
    if [ "$BUILD_TYPE" == "development" ]; then
        backend_dockerfile="$BACKEND_DIR/Dockerfile.dev"
        frontend_dockerfile="$FRONTEND_DIR/Dockerfile.dev"
    else
        backend_dockerfile="$BACKEND_DIR/Dockerfile"
        frontend_dockerfile="$FRONTEND_DIR/Dockerfile"
    fi
    
    # Build Backend
    if build_image "Backend" "$BACKEND_DIR" "$backend_dockerfile" "$backend_tag"; then
        if [ "$RUN_TESTS" == "true" ]; then
            test_image "Backend" "$backend_tag" "8000" "/health" || exit_code=1
            scan_image "Backend" "$backend_tag"
            analyze_image "Backend" "$backend_tag"
        fi
    else
        exit_code=1
    fi
    
    echo ""
    
    # Build Frontend
    if build_image "Frontend" "$FRONTEND_DIR" "$frontend_dockerfile" "$frontend_tag"; then
        if [ "$RUN_TESTS" == "true" ]; then
            test_image "Frontend" "$frontend_tag" "3000" "/" || exit_code=1
            scan_image "Frontend" "$frontend_tag"
            analyze_image "Frontend" "$frontend_tag"
        fi
    else
        exit_code=1
    fi
    
    echo ""
    
    # Push to registry if requested
    if [ "$PUSH_TO_REGISTRY" == "true" ] && [ $exit_code -eq 0 ]; then
        echo -e "${YELLOW}Pushing images to registry...${NC}"
        
        # Tag for registry
        docker tag "$backend_tag" "$REGISTRY/$(basename "$PROJECT_ROOT")-backend:test"
        docker tag "$frontend_tag" "$REGISTRY/$(basename "$PROJECT_ROOT")-frontend:test"
        
        # Push
        docker push "$REGISTRY/$(basename "$PROJECT_ROOT")-backend:test"
        docker push "$REGISTRY/$(basename "$PROJECT_ROOT")-frontend:test"
        
        echo -e "${GREEN}✓ Images pushed to registry${NC}"
    fi
    
    # Summary
    echo ""
    echo "================================"
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Docker build test completed successfully${NC}"
    else
        echo -e "${RED}✗ Docker build test failed${NC}"
    fi
    
    # Cleanup test images
    echo ""
    echo "Cleaning up test images..."
    docker rmi "$backend_tag" 2>/dev/null || true
    docker rmi "$frontend_tag" 2>/dev/null || true
    
    exit $exit_code
}

# Run main function
main