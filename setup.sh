#!/bin/bash

# DevContainer Setup Script - Framework Agnostic

echo "Setting up DevContainer..."

# Load environment variables from .env if it exists
ENV_FILE="${PWD}/.env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    set -a
    source <(grep -v '^#' "$ENV_FILE" | grep -v '^$')
    set +a
else
    echo "No .env file found at $ENV_FILE"
fi

# Wait for Docker to be available (Docker-in-Docker)
while ! docker info > /dev/null 2>&1; do
    echo "Waiting for Docker daemon to be available..."
    sleep 2
done

echo "Docker is ready!"

# Install Claude Code CLI if not already installed
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
    # Ensure it's in PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "Claude Code CLI already installed"
fi

# Check if project has docker-compose.yml
if [ -f "${PWD}/docker-compose.yml" ] || [ -f "${PWD}/docker-compose.yaml" ]; then
    echo "Found docker-compose.yml in project"

    # Check if user wants to start services
    if [ -z "$SKIP_COMPOSE_UP" ]; then
        echo "Starting project services..."
        cd "${PWD}"
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

# Add Context7 MCP server
claude mcp add context7 npx -y @upstash/context7-mcp 2>/dev/null || echo "Note: Run 'claude mcp add context7 npx -y @upstash/context7-mcp' manually if needed"

# Add GitHub MCP server (requires GITHUB_PERSONAL_ACCESS_TOKEN)
if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "Configuring GitHub MCP server..."
    claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PERSONAL_ACCESS_TOKEN" -- \
        docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN \
        ghcr.io/github/github-mcp-server 2>/dev/null || echo "Note: GitHub MCP server configuration failed"
else
    echo "Note: GITHUB_PERSONAL_ACCESS_TOKEN not set - GitHub MCP server not configured"
    echo "To configure manually: claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=your_token -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server"
fi

echo ""
echo "DevContainer setup complete!"
echo "Type 'devhelp' for available commands"