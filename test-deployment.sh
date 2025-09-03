#!/bin/bash

# Containerized Deployment Test Suite
# Tests the complete Docker deployment including health, connectivity, and performance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:3000}"
TEST_TIMEOUT=30
HEALTH_CHECK_RETRIES=10
HEALTH_CHECK_DELAY=3

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to print colored output
print_color() {
    echo -e "${1}${2}${NC}"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    print_color "$BLUE" "Running: $test_name"
    
    if eval "$test_command"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        print_color "$GREEN" "✓ $test_name passed"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        print_color "$RED" "✗ $test_name failed"
    fi
    echo ""
}

# Function to check if a service is healthy
check_health() {
    local service_name="$1"
    local health_url="$2"
    local retries=$HEALTH_CHECK_RETRIES
    
    while [ $retries -gt 0 ]; do
        if curl -s -f "$health_url" > /dev/null 2>&1; then
            return 0
        fi
        retries=$((retries - 1))
        if [ $retries -gt 0 ]; then
            sleep $HEALTH_CHECK_DELAY
        fi
    done
    
    return 1
}

# Function to measure response time
measure_response_time() {
    local url="$1"
    curl -s -o /dev/null -w "%{time_total}" "$url" 2>/dev/null || echo "999"
}

# Function to check HTTP status code
check_http_status() {
    local url="$1"
    local expected_status="$2"
    
    actual_status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    [ "$actual_status" = "$expected_status" ]
}

# Function to check JSON response
check_json_field() {
    local url="$1"
    local field="$2"
    local expected_value="$3"
    
    actual_value=$(curl -s "$url" 2>/dev/null | jq -r "$field" 2>/dev/null)
    [ "$actual_value" = "$expected_value" ]
}

# Function to test container status
test_container_status() {
    # Check if all containers are running
    local running_count=$(docker compose ps --format json 2>/dev/null | jq -r '.[] | select(.State == "running")' | wc -l)
    local total_count=$(docker compose ps --format json 2>/dev/null | jq -r '.[]' | wc -l)
    [ "$running_count" -eq "$total_count" ] && [ "$total_count" -gt 0 ]
}

# Function to test container health
test_container_health() {
    local container_name="$1"
    docker inspect "$container_name" | jq -e '.[0].State.Health.Status == "healthy"' > /dev/null 2>&1
}

# Main test execution
main() {
    print_color "$BLUE" "========================================="
    print_color "$BLUE" "   Containerized Deployment Test Suite"
    print_color "$BLUE" "========================================="
    echo ""
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        print_color "$RED" "Error: Docker is not running"
        exit 1
    fi
    
    # Check if containers are running
    if ! docker compose ps | grep -q "running"; then
        print_color "$YELLOW" "Containers not running. Starting them..."
        docker compose up -d
        sleep 5
    fi
    
    print_color "$YELLOW" "Starting tests..."
    echo ""
    
    # 1. Container Status Tests
    print_color "$BLUE" "=== Container Status Tests ==="
    run_test "Docker Compose services running" "test_container_status"
    run_test "Backend container healthy" "test_container_health fastapi-backend"
    run_test "Frontend container healthy" "test_container_health nextjs-frontend"
    
    # 2. Backend Health Tests
    print_color "$BLUE" "=== Backend Health Tests ==="
    run_test "Backend service is reachable" "check_health 'Backend' '$BACKEND_URL/health'"
    run_test "Backend health endpoint returns 200" "check_http_status '$BACKEND_URL/health' 200"
    run_test "Backend health status is healthy" "check_json_field '$BACKEND_URL/health' '.status' 'healthy'"
    run_test "Backend readiness check passes" "check_json_field '$BACKEND_URL/ready' '.status' 'ready'"
    run_test "Backend liveness check passes" "check_json_field '$BACKEND_URL/live' '.status' 'alive'"
    
    # 3. Backend API Tests
    print_color "$BLUE" "=== Backend API Tests ==="
    run_test "Backend configuration endpoint" "check_http_status '$BACKEND_URL/config' 200"
    run_test "Backend API docs available" "check_http_status '$BACKEND_URL/docs' 200"
    run_test "Backend OpenAPI schema available" "check_http_status '$BACKEND_URL/openapi.json' 200"
    
    # 4. Frontend Health Tests
    print_color "$BLUE" "=== Frontend Health Tests ==="
    run_test "Frontend service is reachable" "check_health 'Frontend' '$FRONTEND_URL/health.json'"
    run_test "Frontend health endpoint returns 200" "check_http_status '$FRONTEND_URL/health.json' 200"
    run_test "Frontend health status is healthy" "check_json_field '$FRONTEND_URL/health.json' '.status' 'healthy'"
    
    # 5. Frontend Page Tests
    print_color "$BLUE" "=== Frontend Page Tests ==="
    run_test "Frontend home page loads" "check_http_status '$FRONTEND_URL/' 200"
    run_test "Frontend dashboard page loads" "check_http_status '$FRONTEND_URL/dashboard' 200"
    run_test "Frontend API test page loads" "check_http_status '$FRONTEND_URL/api-test' 200"
    
    # 6. Service Communication Tests
    print_color "$BLUE" "=== Service Communication Tests ==="
    run_test "Frontend can reach backend" "docker compose exec frontend wget -q -O /dev/null http://backend:8000/health"
    run_test "Backend is accessible from frontend network" "docker compose exec frontend ping -c 1 backend > /dev/null 2>&1"
    
    # 7. Performance Tests
    print_color "$BLUE" "=== Performance Tests ==="
    
    backend_response_time=$(measure_response_time "$BACKEND_URL/health")
    frontend_response_time=$(measure_response_time "$FRONTEND_URL/")
    
    run_test "Backend health check < 500ms" "awk -v time=\"$backend_response_time\" 'BEGIN {exit !(time < 0.5)}'"
    run_test "Frontend home page < 2s" "awk -v time=\"$frontend_response_time\" 'BEGIN {exit !(time < 2)}'"
    
    print_color "$YELLOW" "Backend response time: ${backend_response_time}s"
    print_color "$YELLOW" "Frontend response time: ${frontend_response_time}s"
    echo ""
    
    # 8. Volume Tests
    print_color "$BLUE" "=== Volume Tests ==="
    run_test "Backend logs volume exists" "docker volume ls | grep -q backend-logs"
    run_test "Backend logs are being written" "docker compose exec backend test -f /app/logs/app.log || docker compose exec backend test -d /app/logs"
    
    # 9. Network Tests
    print_color "$BLUE" "=== Network Tests ==="
    run_test "Docker network exists" "docker network ls | grep -q fastapi-nextjs-network"
    run_test "Containers on same network" "docker inspect fastapi-backend nextjs-frontend | jq -e '.[].NetworkSettings.Networks.\"fastapi-nextjs-network\" != null' > /dev/null"
    
    # 10. Environment Configuration Tests
    print_color "$BLUE" "=== Environment Configuration Tests ==="
    run_test "Backend environment is development" "check_json_field '$BACKEND_URL/config' '.ENVIRONMENT' 'development'"
    run_test "Backend debug mode enabled" "check_json_field '$BACKEND_URL/config' '.DEBUG' 'true'"
    run_test "Backend CORS configured" "curl -s '$BACKEND_URL/config' | jq -e '.ALLOWED_ORIGINS | contains([\"http://localhost:3000\"])' > /dev/null"
    
    # 11. Container Resource Tests
    print_color "$BLUE" "=== Container Resource Tests ==="
    backend_memory=$(docker stats --no-stream --format "{{.MemUsage}}" fastapi-backend | awk '{print $1}' | sed 's/MiB//')
    frontend_memory=$(docker stats --no-stream --format "{{.MemUsage}}" nextjs-frontend | awk '{print $1}' | sed 's/MiB//')
    
    print_color "$YELLOW" "Backend memory usage: ${backend_memory}"
    print_color "$YELLOW" "Frontend memory usage: ${frontend_memory}"
    echo ""
    
    # 12. Security Tests
    print_color "$BLUE" "=== Security Tests ==="
    run_test "Backend not running as root" "docker compose exec backend id -u | grep -v '^0$' > /dev/null"
    run_test "Frontend not running as root" "docker compose exec frontend id -u | grep -v '^0$' > /dev/null"
    run_test "Sensitive config values redacted" "curl -s '$BACKEND_URL/config' | grep -q '\\*\\*\\*REDACTED\\*\\*\\*'"
    
    # Print summary
    echo ""
    print_color "$BLUE" "========================================="
    print_color "$BLUE" "           Test Summary"
    print_color "$BLUE" "========================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_color "$GREEN" "All tests passed! ✓"
    else
        print_color "$YELLOW" "Some tests failed"
    fi
    
    print_color "$GREEN" "Passed: $TESTS_PASSED/$TESTS_TOTAL"
    if [ $TESTS_FAILED -gt 0 ]; then
        print_color "$RED" "Failed: $TESTS_FAILED/$TESTS_TOTAL"
    fi
    
    # Exit with appropriate code
    if [ $TESTS_FAILED -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"