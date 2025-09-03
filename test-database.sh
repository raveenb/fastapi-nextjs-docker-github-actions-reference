#!/bin/bash

# Database Connectivity Test Script
# Tests PostgreSQL database setup and connectivity

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_USER="${POSTGRES_USER:-fastapi}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-fastapi_password}"
POSTGRES_DB="${POSTGRES_DB:-fastapi_db}"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print colored output
print_color() {
    echo -e "${1}${2}${NC}"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
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

# Function to check if container is running
check_container() {
    docker ps | grep -q postgres-db
}

# Function to check database connectivity
check_connectivity() {
    docker compose exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1
}

# Function to run SQL query
run_sql() {
    local query="$1"
    docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c "$query" 2>/dev/null
}

# Main test execution
main() {
    print_color "$BLUE" "========================================="
    print_color "$BLUE" "      Database Connectivity Tests"
    print_color "$BLUE" "========================================="
    echo ""
    
    # Start containers if not running
    if ! docker compose ps | grep -q "postgres.*running"; then
        print_color "$YELLOW" "Starting database container..."
        docker compose up -d postgres
        sleep 5
    fi
    
    # 1. Container Tests
    print_color "$BLUE" "=== Container Tests ==="
    run_test "PostgreSQL container is running" "check_container"
    run_test "PostgreSQL container is healthy" "docker compose ps postgres | grep -q healthy"
    
    # 2. Connectivity Tests
    print_color "$BLUE" "=== Connectivity Tests ==="
    run_test "Database is ready" "check_connectivity"
    run_test "Can connect to database" "run_sql 'SELECT 1' | grep -q 1"
    
    # 3. Database Structure Tests
    print_color "$BLUE" "=== Database Structure Tests ==="
    run_test "App schema exists" "run_sql \"SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'app'\" | grep -q app"
    run_test "Users table exists" "run_sql \"SELECT table_name FROM information_schema.tables WHERE table_schema = 'app' AND table_name = 'users'\" | grep -q users"
    run_test "Sessions table exists" "run_sql \"SELECT table_name FROM information_schema.tables WHERE table_schema = 'app' AND table_name = 'sessions'\" | grep -q sessions"
    run_test "Items table exists" "run_sql \"SELECT table_name FROM information_schema.tables WHERE table_schema = 'app' AND table_name = 'items'\" | grep -q items"
    run_test "Audit logs table exists" "run_sql \"SELECT table_name FROM information_schema.tables WHERE table_schema = 'app' AND table_name = 'audit_logs'\" | grep -q audit_logs"
    run_test "Feature flags table exists" "run_sql \"SELECT table_name FROM information_schema.tables WHERE table_schema = 'app' AND table_name = 'feature_flags'\" | grep -q feature_flags"
    
    # 4. Extension Tests
    print_color "$BLUE" "=== Extension Tests ==="
    run_test "UUID extension installed" "run_sql \"SELECT extname FROM pg_extension WHERE extname = 'uuid-ossp'\" | grep -q uuid-ossp"
    run_test "Pgcrypto extension installed" "run_sql \"SELECT extname FROM pg_extension WHERE extname = 'pgcrypto'\" | grep -q pgcrypto"
    
    # 5. Function Tests
    print_color "$BLUE" "=== Function Tests ==="
    run_test "Health check function exists" "run_sql \"SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'app' AND routine_name = 'health_check'\" | grep -q health_check"
    run_test "Ping function exists" "run_sql \"SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'app' AND routine_name = 'ping'\" | grep -q ping"
    run_test "Ping function works" "run_sql \"SELECT app.ping()\" | grep -q pong"
    
    # 6. Data Tests
    print_color "$BLUE" "=== Data Tests ==="
    run_test "Default admin user exists" "run_sql \"SELECT username FROM app.users WHERE username = 'admin'\" | grep -q admin"
    run_test "Feature flags populated" "run_sql \"SELECT COUNT(*) FROM app.feature_flags\" | grep -q 5"
    
    # 7. Index Tests
    print_color "$BLUE" "=== Index Tests ==="
    run_test "Users email index exists" "run_sql \"SELECT indexname FROM pg_indexes WHERE schemaname = 'app' AND tablename = 'users' AND indexname = 'idx_users_email'\" | grep -q idx_users_email"
    run_test "Sessions user_id index exists" "run_sql \"SELECT indexname FROM pg_indexes WHERE schemaname = 'app' AND tablename = 'sessions' AND indexname = 'idx_sessions_user_id'\" | grep -q idx_sessions_user_id"
    
    # 8. Trigger Tests
    print_color "$BLUE" "=== Trigger Tests ==="
    run_test "Users updated_at trigger exists" "run_sql \"SELECT trigger_name FROM information_schema.triggers WHERE event_object_schema = 'app' AND event_object_table = 'users' AND trigger_name = 'set_timestamp'\" | grep -q set_timestamp"
    
    # 9. Performance Tests
    print_color "$BLUE" "=== Performance Tests ==="
    local health_check_time=$(run_sql "SELECT EXTRACT(EPOCH FROM (SELECT (SELECT NOW()) - (SELECT NOW() - INTERVAL '1 second')))" | tr -d ' ')
    run_test "Health check completes quickly" "[ -n \"$health_check_time\" ]"
    
    # 10. Volume Tests
    print_color "$BLUE" "=== Volume Tests ==="
    run_test "Database volume exists" "docker volume ls | grep -q postgres-data"
    
    # Print database info
    print_color "$BLUE" "=== Database Information ==="
    print_color "$YELLOW" "Database Size: $(run_sql \"SELECT pg_size_pretty(pg_database_size('$POSTGRES_DB'))\" | tr -d ' ')"
    print_color "$YELLOW" "Table Count: $(run_sql \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'app'\" | tr -d ' ')"
    print_color "$YELLOW" "Active Connections: $(run_sql \"SELECT COUNT(*) FROM pg_stat_activity\" | tr -d ' ')"
    echo ""
    
    # Print summary
    print_color "$BLUE" "========================================="
    print_color "$BLUE" "           Test Summary"
    print_color "$BLUE" "========================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        print_color "$GREEN" "All tests passed! ✓"
    else
        print_color "$YELLOW" "Some tests failed"
    fi
    
    print_color "$GREEN" "Passed: $TESTS_PASSED/$((TESTS_PASSED + TESTS_FAILED))"
    if [ $TESTS_FAILED -gt 0 ]; then
        print_color "$RED" "Failed: $TESTS_FAILED/$((TESTS_PASSED + TESTS_FAILED))"
        exit 1
    fi
}

# Run main function
main "$@"