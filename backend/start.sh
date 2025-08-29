#!/bin/bash

# GitAlong Backend Startup Script
# This script handles both development and production startup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if virtual environment exists
check_venv() {
    if [[ "$VIRTUAL_ENV" == "" ]]; then
        print_warning "No virtual environment detected. Creating one..."
        python -m venv venv
        source venv/bin/activate
        print_success "Virtual environment created and activated"
    else
        print_success "Virtual environment already active: $VIRTUAL_ENV"
    fi
}

# Function to install dependencies
install_dependencies() {
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    print_success "Dependencies installed successfully"
}

# Function to check environment file
check_env_file() {
    if [[ ! -f .env ]]; then
        print_warning ".env file not found. Creating from example..."
        if [[ -f .env.example ]]; then
            cp .env.example .env
            print_warning "Please edit .env file with your configuration before starting"
            exit 1
        else
            print_error ".env.example file not found"
            exit 1
        fi
    fi
}

# Function to run database migrations
run_migrations() {
    print_status "Running database migrations..."
    if command_exists alembic; then
        alembic upgrade head
        print_success "Database migrations completed"
    else
        print_warning "Alembic not found. Skipping migrations..."
    fi
}

# Function to start development server
start_development() {
    print_status "Starting development server..."
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
}

# Function to start production server
start_production() {
    print_status "Starting production server..."
    gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
}

# Function to start with Docker
start_docker() {
    print_status "Starting with Docker Compose..."
    if command_exists docker-compose; then
        docker-compose up -d
        print_success "Services started with Docker Compose"
        print_status "Backend available at: http://localhost:8000"
        print_status "API docs available at: http://localhost:8000/docs"
    else
        print_error "Docker Compose not found. Please install Docker and Docker Compose"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "GitAlong Backend Startup Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  dev, development    Start development server with hot reload"
    echo "  prod, production    Start production server with Gunicorn"
    echo "  docker              Start with Docker Compose"
    echo "  install             Install dependencies only"
    echo "  migrate             Run database migrations only"
    echo "  help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev              # Start development server"
    echo "  $0 production       # Start production server"
    echo "  $0 docker           # Start with Docker"
    echo ""
}

# Main script logic
main() {
    case "${1:-dev}" in
        "dev"|"development")
            print_status "Starting in development mode..."
            check_venv
            install_dependencies
            check_env_file
            run_migrations
            start_development
            ;;
        "prod"|"production")
            print_status "Starting in production mode..."
            check_venv
            install_dependencies
            check_env_file
            run_migrations
            start_production
            ;;
        "docker")
            start_docker
            ;;
        "install")
            check_venv
            install_dependencies
            print_success "Installation completed"
            ;;
        "migrate")
            check_venv
            run_migrations
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
