#!/bin/bash

# DevContainer Setup Script - Framework Agnostic

echo "Setting up DevContainer..."

# Load environment variables from .env if it exists
if [ -f "/workspace/.env" ]; then
    set -a
    source <(grep -v '^#' /workspace/.env | grep -v '^$')
    set +a
fi

# Wait for Docker to be available (Docker-in-Docker)
while ! docker info > /dev/null 2>&1; do
    echo "Waiting for Docker daemon to be available..."
    sleep 2
done

echo "Docker is ready!"

# Check if project has docker-compose.yml
if [ -f "/workspace/docker-compose.yml" ] || [ -f "/workspace/docker-compose.yaml" ]; then
    echo "Found docker-compose.yml in project"
    
    # Check if user wants to start services
    if [ -z "$SKIP_COMPOSE_UP" ]; then
        echo "Starting project services..."
        cd /workspace
        docker-compose up -d
        
        # Wait a moment for containers to start
        sleep 5
        
        # Show running containers
        echo ""
        echo "Running containers:"
        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    else
        echo "Skipping docker-compose up (SKIP_COMPOSE_UP is set)"
    fi
else
    echo "No docker-compose.yml found in project root"
    echo "You can create your own or run containers manually"
fi

# Configure MCP servers for Claude Code
echo "Configuring MCP servers..."
claude mcp add context7 npx @upstash/context7 2>/dev/null || echo "Note: Run 'claude mcp add context7 npx @upstash/context7' manually if needed"

echo ""
echo "DevContainer setup complete!"
echo "Type 'devhelp' for available commands"