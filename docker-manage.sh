#!/bin/bash

# Docker Compose management script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to print colored output
print_color() {
    echo -e "${1}${2}${NC}"
}

# Function to check if .env file exists
check_env() {
    if [ ! -f .env ]; then
        print_color "$YELLOW" "⚠ .env file not found. Creating from .env.example..."
        cp .env.example .env
        print_color "$GREEN" "✓ .env file created. Please update it with your configuration."
    fi
}

# Function to build images
build() {
    print_color "$BLUE" "Building Docker images..."
    if [ "$1" = "dev" ]; then
        docker-compose -f docker-compose.dev.yml build
    else
        docker-compose build
    fi
    print_color "$GREEN" "✓ Images built successfully"
}

# Function to start services
up() {
    check_env
    if [ "$1" = "dev" ]; then
        print_color "$BLUE" "Starting development services..."
        docker-compose -f docker-compose.dev.yml up -d
        print_color "$GREEN" "✓ Development services started"
        print_color "$YELLOW" "Frontend: http://localhost:3000"
        print_color "$YELLOW" "Backend: http://localhost:8000"
        print_color "$YELLOW" "API Docs: http://localhost:8000/docs"
    else
        print_color "$BLUE" "Starting production services..."
        docker-compose up -d
        print_color "$GREEN" "✓ Production services started"
        print_color "$YELLOW" "Frontend: http://localhost:3000"
        print_color "$YELLOW" "Backend: http://localhost:8000"
    fi
}

# Function to stop services
down() {
    print_color "$BLUE" "Stopping services..."
    if [ "$1" = "dev" ]; then
        docker-compose -f docker-compose.dev.yml down
    else
        docker-compose down
    fi
    print_color "$GREEN" "✓ Services stopped"
}

# Function to view logs
logs() {
    if [ "$1" = "dev" ]; then
        docker-compose -f docker-compose.dev.yml logs -f ${2:-}
    else
        docker-compose logs -f ${2:-}
    fi
}

# Function to restart services
restart() {
    down "$1"
    up "$1"
}

# Function to execute command in container
exec_cmd() {
    if [ "$1" = "dev" ]; then
        shift
        docker-compose -f docker-compose.dev.yml exec "$@"
    else
        shift
        docker-compose exec "$@"
    fi
}

# Function to clean up
clean() {
    print_color "$YELLOW" "⚠ This will remove all containers, volumes, and images for this project."
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_color "$BLUE" "Cleaning up Docker resources..."
        docker-compose down -v --remove-orphans
        docker-compose -f docker-compose.dev.yml down -v --remove-orphans
        docker image rm -f $(docker image ls -q 'fastapi-*' 'nextjs-*' 2>/dev/null) 2>/dev/null || true
        print_color "$GREEN" "✓ Cleanup complete"
    else
        print_color "$YELLOW" "Cleanup cancelled"
    fi
}

# Function to show status
status() {
    print_color "$BLUE" "Service Status:"
    if [ "$1" = "dev" ]; then
        docker-compose -f docker-compose.dev.yml ps
    else
        docker-compose ps
    fi
}

# Function to run tests
test() {
    print_color "$BLUE" "Running tests..."
    if [ "$1" = "backend" ] || [ -z "$1" ]; then
        print_color "$YELLOW" "Running backend tests..."
        docker-compose exec backend pytest
    fi
    if [ "$1" = "frontend" ] || [ -z "$1" ]; then
        print_color "$YELLOW" "Running frontend tests..."
        docker-compose exec frontend pnpm test
    fi
    print_color "$GREEN" "✓ Tests complete"
}

# Main script logic
case "$1" in
    build)
        build "$2"
        ;;
    up|start)
        up "$2"
        ;;
    down|stop)
        down "$2"
        ;;
    restart)
        restart "$2"
        ;;
    logs)
        logs "$2" "$3"
        ;;
    exec)
        shift
        exec_cmd "$@"
        ;;
    status|ps)
        status "$2"
        ;;
    test)
        test "$2"
        ;;
    clean)
        clean
        ;;
    *)
        print_color "$BLUE" "Docker Compose Management Script"
        echo ""
        echo "Usage: $0 {command} [options]"
        echo ""
        echo "Commands:"
        echo "  build [dev]        Build Docker images"
        echo "  up|start [dev]     Start services"
        echo "  down|stop [dev]    Stop services"
        echo "  restart [dev]      Restart services"
        echo "  logs [dev] [service] View logs"
        echo "  exec [dev] <service> <command>  Execute command in container"
        echo "  status|ps [dev]    Show service status"
        echo "  test [backend|frontend] Run tests"
        echo "  clean              Remove all containers, volumes, and images"
        echo ""
        echo "Examples:"
        echo "  $0 build           # Build production images"
        echo "  $0 build dev       # Build development images"
        echo "  $0 up              # Start production services"
        echo "  $0 up dev          # Start development services"
        echo "  $0 logs backend    # View backend logs"
        echo "  $0 exec backend bash  # Open bash shell in backend"
        echo "  $0 test            # Run all tests"
        exit 1
        ;;
esac