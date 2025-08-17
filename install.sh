#!/bin/bash

# Universal DevContainer Web Installer
# Can be run via: curl -fsSL https://example.com/install.sh | bash
# Or with target: curl -fsSL https://example.com/install.sh | bash -s -- /path/to/project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    echo -e "${2}${1}${NC}"
}

# GitHub repository URL (update this to your repo)
REPO_URL="https://github.com/yourusername/devcontainer-template"
REPO_RAW_URL="https://raw.githubusercontent.com/yourusername/devcontainer-template/main"

# Get target directory (default to current directory)
TARGET_DIR="${1:-.}"

# Resolve to absolute path
if [ "$TARGET_DIR" = "." ]; then
    TARGET_DIR="$(pwd)"
else
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
        print_message "Error: Directory $TARGET_DIR does not exist" "$RED"
        exit 1
    }
fi

print_message "╔════════════════════════════════════════╗" "$BLUE"
print_message "║   Universal DevContainer Installer    ║" "$BLUE"
print_message "╚════════════════════════════════════════╝" "$BLUE"
echo ""

print_message "Target directory: $TARGET_DIR" "$GREEN"

# Check if target is a valid directory
if [ ! -d "$TARGET_DIR" ]; then
    print_message "Error: Target directory does not exist." "$RED"
    exit 1
fi

# Detect project type
print_message "Detecting project type..." "$YELLOW"
if [ -f "$TARGET_DIR/composer.json" ]; then
    if [ -f "$TARGET_DIR/artisan" ]; then
        print_message "✓ Detected Laravel project" "$GREEN"
    else
        print_message "✓ Detected PHP/Composer project" "$GREEN"
    fi
elif [ -f "$TARGET_DIR/package.json" ]; then
    print_message "✓ Detected Node.js project" "$GREEN"
elif [ -f "$TARGET_DIR/requirements.txt" ] || [ -f "$TARGET_DIR/Pipfile" ]; then
    print_message "✓ Detected Python project" "$GREEN"
elif [ -f "$TARGET_DIR/go.mod" ]; then
    print_message "✓ Detected Go project" "$GREEN"
else
    print_message "→ No specific project type detected - installing universal DevContainer" "$YELLOW"
fi

# Check if .devcontainer already exists
if [ -d "$TARGET_DIR/.devcontainer" ]; then
    print_message "⚠ Found existing .devcontainer directory." "$YELLOW"
    read -p "Backup and replace? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="$TARGET_DIR/.devcontainer.backup.$(date +%Y%m%d%H%M%S)"
        print_message "→ Backing up to: $BACKUP_DIR" "$GREEN"
        mv "$TARGET_DIR/.devcontainer" "$BACKUP_DIR"
    else
        print_message "Installation cancelled." "$RED"
        exit 1
    fi
fi

# Create .devcontainer directory
print_message "Creating .devcontainer directory..." "$YELLOW"
mkdir -p "$TARGET_DIR/.devcontainer"

# Download files from GitHub
print_message "Downloading DevContainer files..." "$YELLOW"

# Function to download a file
download_file() {
    local file=$1
    local url="$REPO_RAW_URL/.devcontainer/$file"
    local dest="$TARGET_DIR/.devcontainer/$file"
    
    if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
        print_message "  ✓ Downloaded $file" "$GREEN"
        return 0
    else
        print_message "  ✗ Failed to download $file" "$RED"
        return 1
    fi
}

# Download all required files
download_file "devcontainer.json" || exit 1
download_file "docker-compose.yml" || exit 1
download_file "Dockerfile" || exit 1
download_file "setup.sh" || exit 1
download_file ".bashrc" || exit 1

# Make scripts executable
chmod +x "$TARGET_DIR/.devcontainer/setup.sh"

# Update .gitignore if it exists
if [ -f "$TARGET_DIR/.gitignore" ]; then
    if ! grep -q "# DevContainer" "$TARGET_DIR/.gitignore"; then
        print_message "Updating .gitignore..." "$YELLOW"
        echo "" >> "$TARGET_DIR/.gitignore"
        echo "# DevContainer" >> "$TARGET_DIR/.gitignore"
        echo ".devcontainer/docker-compose.override.yml" >> "$TARGET_DIR/.gitignore"
        echo ".devcontainer-config" >> "$TARGET_DIR/.gitignore"
        print_message "  ✓ Updated .gitignore" "$GREEN"
    fi
fi

# Create configuration example
cat > "$TARGET_DIR/.devcontainer-config.example" << 'EOF'
# DevContainer Configuration Example
# Copy this to .devcontainer-config and customize

# Specify container names if auto-detection doesn't work
# APP_CONTAINER=my-app-container
# NODE_CONTAINER=my-node-container
# DB_CONTAINER=my-database-container

# Database connection settings (for 'db' command)
# DB_USER=root
# DB_PASSWORD=password
# DB_NAME=myapp

# Skip auto-starting docker-compose
# SKIP_COMPOSE_UP=true
EOF

print_message "  ✓ Created .devcontainer-config.example" "$GREEN"

# Success message
echo ""
print_message "╔════════════════════════════════════════╗" "$GREEN"
print_message "║     Installation Complete! 🎉         ║" "$GREEN"
print_message "╚════════════════════════════════════════╝" "$GREEN"
echo ""

print_message "Next steps:" "$BLUE"
echo "  1. Open VS Code in: $TARGET_DIR"
echo "  2. Install 'Remote - Containers' extension"
echo "  3. Press F1 → 'Remote-Containers: Reopen in Container'"
echo "  4. VS Code will build and start the DevContainer"
echo ""

print_message "Quick commands:" "$BLUE"
echo "  • devhelp    - Show available commands"
echo "  • dcup       - Start your project containers"
echo "  • containers - Show running containers"
echo ""

print_message "Configuration:" "$BLUE"
echo "  • Copy .devcontainer-config.example to .devcontainer-config"
echo "  • Customize container names and settings as needed"
echo ""

print_message "Documentation:" "$BLUE"
echo "  $REPO_URL"
echo ""

# Check if VS Code is installed
if command -v code &> /dev/null; then
    read -p "Open in VS Code now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        code "$TARGET_DIR"
        print_message "VS Code opened. Use 'Reopen in Container' from the command palette." "$GREEN"
    fi
fi