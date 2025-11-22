#!/bin/bash
# DevContainer Configuration - Framework Agnostic Base
# This file loads framework-specific helpers based on DEVCONTAINER_FRAMEWORK env variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Load framework-specific helpers if specified in project .env
if [ -f "/workspace/.env" ]; then
    FRAMEWORK=$(grep -E "^DEVCONTAINER_FRAMEWORK=" /workspace/.env 2>/dev/null | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    if [ -n "$FRAMEWORK" ]; then
        FRAMEWORK_BASHRC="/workspace/.devcontainer/${FRAMEWORK}/.bashrc"
        if [ -f "$FRAMEWORK_BASHRC" ]; then
            source "$FRAMEWORK_BASHRC"
            # Framework .bashrc loaded, exit early
            return 0
        else
            echo -e "${YELLOW}Warning: DEVCONTAINER_FRAMEWORK=${FRAMEWORK} set but ${FRAMEWORK_BASHRC} not found${NC}"
            echo -e "${YELLOW}Available frameworks: laravel${NC}"
        fi
    fi
fi

# Generic Docker Compose aliases (only loaded if no framework specified)
alias dc="docker-compose"
alias dcup="docker-compose up -d"
alias dcdown="docker-compose down"
alias dclogs="docker-compose logs -f"
alias dcps="docker-compose ps"
alias dcrestart="docker-compose restart"

# Container inspection
alias containers="docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'"

# Claude Code CLI alias (always available)
alias claude='claude --dangerously-skip-permissions --permission-mode bypassPermissions'
alias claude-monitor='claude-monitor'
alias cm='claude-monitor'

# Show available commands
devhelp() {
    echo -e "${GREEN}=== DevContainer Helper Commands ===${NC}"
    echo ""
    echo -e "${CYAN}Docker:${NC}"
    echo "  dc, dcup, dcdown  - Docker Compose shortcuts"
    echo "  containers        - Show running containers"
    echo ""
    echo -e "${CYAN}Tools:${NC}"
    echo "  claude            - Claude Code CLI"
    echo "  claude-monitor, cm - Claude Monitor (usage tracking)"
    echo ""
    echo -e "${YELLOW}No framework loaded!${NC}"
    echo "To enable framework-specific commands (artisan, composer, etc.):"
    echo "  1. Add 'DEVCONTAINER_FRAMEWORK=laravel' to your project's .env file"
    echo "  2. Restart your terminal or run: source ~/.bashrc"
    echo ""
    echo "Available frameworks:"
    echo "  - laravel  (see .devcontainer/laravel/README.md)"
}

# Welcome message
echo -e "${GREEN}DevContainer with Claude Code ready!${NC}"

# Check if framework should be loaded
if [ -f "/workspace/.env" ]; then
    if grep -q "^DEVCONTAINER_FRAMEWORK=" /workspace/.env 2>/dev/null; then
        # Already handled above, framework either loaded or warned
        :
    else
        echo -e "${YELLOW}Tip: Add DEVCONTAINER_FRAMEWORK=laravel to your .env to load framework helpers${NC}"
    fi
fi

echo "Type 'devhelp' for available commands"
echo ""

# Auto-detect if docker-compose.yml exists and no containers running
if [ -f "/workspace/docker-compose.yml" ] || [ -f "/workspace/docker-compose.yaml" ]; then
    if [ -z "$(docker ps -q 2>/dev/null)" ]; then
        echo -e "${YELLOW}Found docker-compose.yml but no containers running${NC}"
        echo "Run 'dcup' to start your services"
    fi
fi
