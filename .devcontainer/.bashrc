#!/bin/bash
# DevContainer Configuration - Language/Framework Agnostic
# This file provides auto-detection and dynamic aliases for containers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration file (optional - users can create this)
CONFIG_FILE="/workspace/.devcontainer-config"

# Load project-specific configuration if it exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo -e "${GREEN}Loaded project configuration from .devcontainer-config${NC}"
fi

# Auto-detection functions
find_container_with_command() {
    local cmd=$1
    for container in $(docker ps --format "{{.Names}}" 2>/dev/null); do
        if docker exec $container which $cmd >/dev/null 2>&1; then
            echo $container
            return 0
        fi
    done
    return 1
}

# Detect PHP container
detect_php_container() {
    if [ -n "$APP_CONTAINER" ]; then
        echo $APP_CONTAINER
    else
        find_container_with_command "php"
    fi
}

# Detect Node container
detect_node_container() {
    if [ -n "$NODE_CONTAINER" ]; then
        echo $NODE_CONTAINER
    else
        find_container_with_command "node"
    fi
}

# Detect database container
detect_db_container() {
    if [ -n "$DB_CONTAINER" ]; then
        echo $DB_CONTAINER
        return 0
    fi
    
    # Try common database commands
    for cmd in mysql psql mongosh redis-cli; do
        container=$(find_container_with_command $cmd)
        if [ $? -eq 0 ]; then
            echo $container
            return 0
        fi
    done
    return 1
}

# Dynamic command wrapper
run_in_container() {
    local cmd=$1
    shift
    local container=$(find_container_with_command $cmd)
    
    if [ -z "$container" ]; then
        echo -e "${RED}No container found with '$cmd' command${NC}"
        echo "Make sure your containers are running: docker-compose up -d"
        return 1
    fi
    
    docker exec -it $container $cmd "$@"
}

# Generic Docker Compose aliases
alias dc="docker-compose"
alias dcup="docker-compose up -d"
alias dcdown="docker-compose down"
alias dclogs="docker-compose logs -f"
alias dcps="docker-compose ps"
alias dcrestart="docker-compose restart"

# Container inspection
alias containers="docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'"

# Dynamic aliases - these detect the appropriate container
alias php='run_in_container php'
alias composer='run_in_container composer'
alias node='run_in_container node'
alias npm='run_in_container npm'
alias yarn='run_in_container yarn'
alias python='run_in_container python'
alias pip='run_in_container pip'

# Claude Code CLI alias (always available)
alias claude='claude'
CLAUDE_AVAILABLE=true

# Framework-specific aliases (auto-detect)
artisan() {
    local container=$(detect_php_container)
    if [ -n "$container" ]; then
        docker exec -it $container php artisan "$@"
    else
        echo -e "${RED}No PHP container found${NC}"
    fi
}

symfony() {
    local container=$(detect_php_container)
    if [ -n "$container" ]; then
        docker exec -it $container php bin/console "$@"
    else
        echo -e "${RED}No PHP container found${NC}"
    fi
}


# Database helpers
db() {
    local container=$(detect_db_container)
    if [ -z "$container" ]; then
        echo -e "${RED}No database container found${NC}"
        return 1
    fi
    
    # Detect database type and connect
    if docker exec $container which mysql >/dev/null 2>&1; then
        docker exec -it $container mysql -u${DB_USER:-root} -p${DB_PASSWORD:-root} ${DB_NAME:-}
    elif docker exec $container which psql >/dev/null 2>&1; then
        docker exec -it $container psql -U ${DB_USER:-postgres} ${DB_NAME:-postgres}
    elif docker exec $container which mongosh >/dev/null 2>&1; then
        docker exec -it $container mongosh
    elif docker exec $container which redis-cli >/dev/null 2>&1; then
        docker exec -it $container redis-cli
    else
        echo -e "${YELLOW}Database container found but type unknown${NC}"
        docker exec -it $container bash
    fi
}

# Helper to set up project configuration
setup_project_config() {
    echo "Setting up project configuration..."
    echo "# DevContainer Configuration" > /workspace/.devcontainer-config
    
    # Try to detect containers
    php_container=$(detect_php_container)
    node_container=$(detect_node_container)
    db_container=$(detect_db_container)
    
    if [ -n "$php_container" ]; then
        echo "APP_CONTAINER=$php_container" >> /workspace/.devcontainer-config
    fi
    if [ -n "$node_container" ]; then
        echo "NODE_CONTAINER=$node_container" >> /workspace/.devcontainer-config
    fi
    if [ -n "$db_container" ]; then
        echo "DB_CONTAINER=$db_container" >> /workspace/.devcontainer-config
    fi
    
    echo -e "${GREEN}Configuration saved to .devcontainer-config${NC}"
}

# Show available commands
devhelp() {
    echo -e "${GREEN}DevContainer Helper Commands:${NC}"
    echo "  dc, dcup, dcdown    - Docker Compose shortcuts"
    echo "  containers          - Show running containers"
    echo "  php, composer       - Run in PHP container (auto-detected)"
    echo "  node, npm, yarn     - Run in Node container (auto-detected)"
    echo "  python, pip         - Run in Python container (auto-detected)"
    echo "  artisan            - Laravel commands"
    echo "  symfony            - Symfony console"
    echo "  claude             - Claude Code CLI"
    echo "  db                 - Connect to database"
    echo "  setup_project_config - Create .devcontainer-config"
    echo ""
    echo -e "${YELLOW}Tip: Create .devcontainer-config to set specific container names${NC}"
}

# Welcome message
echo -e "${GREEN}DevContainer with Claude Code ready!${NC}"
echo "Type 'devhelp' for available commands"
echo ""

# Auto-detect if docker-compose.yml exists and no containers running
if [ -f "/workspace/docker-compose.yml" ] || [ -f "/workspace/docker-compose.yaml" ]; then
    if [ -z "$(docker ps -q 2>/dev/null)" ]; then
        echo -e "${YELLOW}Found docker-compose.yml but no containers running${NC}"
        echo "Run 'dcup' to start your services"
    fi
fi