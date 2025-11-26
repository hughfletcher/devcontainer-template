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
DOCKER_WAIT_TIMEOUT=60  # Maximum wait time in seconds
DOCKER_WAIT_ELAPSED=0
while ! docker info > /dev/null 2>&1; do
    if [ $DOCKER_WAIT_ELAPSED -ge $DOCKER_WAIT_TIMEOUT ]; then
        echo "ERROR: Docker daemon failed to start within ${DOCKER_WAIT_TIMEOUT} seconds"
        echo "This may be due to:"
        echo "  - Docker-in-Docker feature not properly initialized"
        echo "  - Permission issues with mounted volumes"
        echo "  - System resource constraints"
        echo "Continuing without Docker..."
        break
    fi
    echo "Waiting for Docker daemon to be available... (${DOCKER_WAIT_ELAPSED}s/${DOCKER_WAIT_TIMEOUT}s)"
    sleep 2
    DOCKER_WAIT_ELAPSED=$((DOCKER_WAIT_ELAPSED + 2))
done

# Check if Docker is actually ready
if docker info > /dev/null 2>&1; then
    echo "Docker is ready!"
else
    echo "Docker is NOT ready - skipping Docker-dependent setup"
fi

# Fix VSCode extensions directory permissions (ensure vscode user owns it)
if [ -d "$HOME/.vscode-server/extensions" ]; then
    echo "Fixing VSCode extensions directory permissions..."
    sudo chown -R vscode:vscode "$HOME/.vscode-server" 2>/dev/null || true
fi

# Install Claude Code CLI if not already installed
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
    # Ensure it's in PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "Claude Code CLI already installed"
fi

# Check if project has docker-compose.yml (only if Docker is ready)
if docker info > /dev/null 2>&1; then
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
else
    echo "Skipping docker-compose check (Docker not ready)"
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

# Laravel-specific setup (if Laravel app exists in src/)
if [ -d "${PWD}/src" ] && [ -f "${PWD}/src/composer.json" ]; then
    echo ""
    echo "Detected Laravel application in src/ directory"

    # Source Laravel bashrc for aliases (php, composer, artisan -> docker-compose exec app)
    if [ -f "${PWD}/.devcontainer/laravel/.bashrc" ]; then
        echo "Loading Laravel aliases..."
        # Add to user's bashrc for future sessions
        if ! grep -q "laravel/.bashrc" "$HOME/.bashrc" 2>/dev/null; then
            echo "source ${PWD}/.devcontainer/laravel/.bashrc" >> "$HOME/.bashrc"
        fi
    fi

    # Wait for app container to be healthy before running Laravel commands
    if docker info > /dev/null 2>&1; then
        echo "Waiting for app container to be ready..."
        WAIT_COUNT=0
        MAX_WAIT=30
        while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
            if docker-compose exec -T app php -v > /dev/null 2>&1; then
                echo "App container is ready!"
                break
            fi
            echo "  Waiting for app container... (${WAIT_COUNT}s)"
            sleep 2
            WAIT_COUNT=$((WAIT_COUNT + 2))
        done

        if [ $WAIT_COUNT -ge $MAX_WAIT ]; then
            echo "Warning: App container not ready after ${MAX_WAIT}s - skipping Laravel setup"
        else
            # Install composer dependencies via app container
            echo "Running composer install via app container..."
            docker-compose exec -T app composer install --no-interaction --prefer-dist --optimize-autoloader || {
                echo "Warning: composer install failed or incomplete"
            }

            # Generate Laravel app key if not set
            if [ -f "${PWD}/src/.env" ]; then
                if ! grep -q "^APP_KEY=base64:" "${PWD}/src/.env"; then
                    echo "Generating Laravel application key..."
                    docker-compose exec -T app php artisan key:generate --no-interaction || {
                        echo "Warning: Laravel key generation failed"
                    }
                else
                    echo "Laravel APP_KEY already set"
                fi
            else
                echo "Note: No .env file found in src/ - skipping key generation"
                echo "Run 'cp src/.env.example src/.env && artisan key:generate' manually"
            fi
        fi
    else
        echo "Docker not ready - skipping Laravel container setup"
        echo "Run 'docker-compose up -d' then 'composer install' manually"
    fi
fi

echo ""
echo "DevContainer setup complete!"
echo "Type 'devhelp' for available commands"