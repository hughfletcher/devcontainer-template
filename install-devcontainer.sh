#!/bin/bash

# Universal DevContainer Installer Script
# Usage: ./install-devcontainer.sh [target-directory]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_message() {
    echo -e "${2}${1}${NC}"
}

# Get target directory (default to current directory)
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Script directory (where this installer is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_DIR="$SCRIPT_DIR"

print_message "Universal DevContainer Installer" "$GREEN"
print_message "================================" "$GREEN"

# Check if target is a valid project directory
if [ ! -d "$TARGET_DIR" ]; then
    print_message "Error: Target directory does not exist." "$RED"
    exit 1
fi

# Detect project type (optional)
if [ -f "$TARGET_DIR/composer.json" ]; then
    print_message "Detected PHP/Composer project" "$GREEN"
elif [ -f "$TARGET_DIR/package.json" ]; then
    print_message "Detected Node.js project" "$GREEN"
elif [ -f "$TARGET_DIR/requirements.txt" ] || [ -f "$TARGET_DIR/Pipfile" ]; then
    print_message "Detected Python project" "$GREEN"
else
    print_message "No specific project type detected - installing universal DevContainer" "$YELLOW"
fi

# Check if .devcontainer already exists
if [ -d "$TARGET_DIR/.devcontainer" ]; then
    print_message "Found existing .devcontainer directory." "$YELLOW"
    read -p "Backup and replace? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BACKUP_DIR="$TARGET_DIR/.devcontainer.backup.$(date +%Y%m%d%H%M%S)"
        print_message "Backing up to: $BACKUP_DIR" "$GREEN"
        mv "$TARGET_DIR/.devcontainer" "$BACKUP_DIR"
    else
        print_message "Installation cancelled." "$RED"
        exit 1
    fi
fi

# Copy template files
print_message "Installing DevContainer files..." "$GREEN"

# Check if template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    print_message "Error: .devcontainer template not found at $TEMPLATE_DIR/.devcontainer" "$RED"
    print_message "Make sure .devcontainer/ exists in the same directory as this script." "$RED"
    exit 1
fi

# Copy the .devcontainer directory
cp -r "$TEMPLATE_DIR/.devcontainer" "$TARGET_DIR/"

# Make scripts executable
chmod +x "$TARGET_DIR/.devcontainer/setup.sh"

# Update .gitignore if it exists
if [ -f "$TARGET_DIR/.gitignore" ]; then
    # Check if entries already exist
    if ! grep -q "# DevContainer" "$TARGET_DIR/.gitignore"; then
        print_message "Updating .gitignore..." "$GREEN"
        echo "" >> "$TARGET_DIR/.gitignore"
        echo "# DevContainer" >> "$TARGET_DIR/.gitignore"
        echo ".devcontainer/docker-compose.override.yml" >> "$TARGET_DIR/.gitignore"
    fi
fi

# Create a docker-compose.override.yml template for local customization
cat > "$TARGET_DIR/.devcontainer/docker-compose.override.yml.example" << 'EOF'
# Local overrides for docker-compose.yml
# Copy this to docker-compose.override.yml and customize as needed
version: '3.8'

services:
  devcontainer:
    environment:
      # Add your custom environment variables here
      # SKIP_COMPOSE_UP: "true"
    # volumes:
    #   - ./custom-config:/custom-config
EOF

print_message "Installation complete!" "$GREEN"
echo ""
print_message "Next steps:" "$GREEN"
echo "1. Open VS Code in the project directory: $TARGET_DIR"
echo "2. Install the 'Remote - Containers' extension if not already installed"
echo "3. Press F1 and select 'Remote-Containers: Reopen in Container'"
echo "4. VS Code will build and start the DevContainer"
echo ""
print_message "Available commands inside the container:" "$YELLOW"
echo "  - Auto-detecting commands based on your project's containers"
echo "  - php, composer, node, npm, python, pip (if containers exist)"
echo "  - artisan, symfony, django, rails (framework commands)"
echo "  - db (auto-connects to database)"
echo "  - devhelp (show all available commands)"
echo ""
print_message "Configuration files:" "$YELLOW"
echo "  - .devcontainer/devcontainer.json (main config)"
echo "  - .devcontainer/docker-compose.yml (services)"
echo "  - .devcontainer/docker-compose.override.yml (local overrides)"
echo ""
print_message "For more information, see the README.md file." "$GREEN"