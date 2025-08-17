# Universal DevContainer Template

A lightweight, framework-agnostic DevContainer that provides an isolated Docker-in-Docker environment for any development project. The container automatically detects and works with your project's services (PHP, Node, Python, databases, etc.).

## Key Features

- **Framework Agnostic**: Works with Laravel, Symfony, Node.js, Python, or any stack
- **Auto-Detection**: Automatically finds and connects to your application containers
- **Isolated Environment**: Docker-in-Docker provides complete isolation
- **Smart Aliases**: Commands like `php`, `composer`, `npm` automatically run in the correct container
- **VS Code Integration**: Full support for Remote-Containers extension with auto port forwarding
- **Persistent Settings**: VS Code extensions and settings persist across rebuilds

## Architecture

```
DevContainer (Ubuntu + Docker-in-Docker)
    └── Your Project's Containers
        ├── App Container (PHP/Python/Node/etc.)
        ├── Database (MySQL/PostgreSQL/MongoDB/etc.)
        └── Other Services (Redis, ElasticSearch, etc.)
```

## Installation

### Quick Install (One-liner)

```bash
# Install directly from GitHub (update URL to your repo)
curl -fsSL https://raw.githubusercontent.com/yourusername/devcontainer-template/main/install.sh | bash

# Or specify a target directory
curl -fsSL https://raw.githubusercontent.com/yourusername/devcontainer-template/main/install.sh | bash -s -- /path/to/project
```

### Local Install

```bash
# Clone this repository
git clone https://github.com/yourusername/devcontainer-template.git
cd devcontainer-template

# Install to your project
./install-devcontainer.sh /path/to/your/project
```

### Manual Installation

1. Copy `.devcontainer` folder to your project root
2. Make setup script executable: `chmod +x .devcontainer/setup.sh`
3. Open in VS Code and select "Reopen in Container"

## Usage

### 1. Open in VS Code

1. Install "Remote - Containers" extension
2. Open your project folder
3. Press `F1` → "Remote-Containers: Reopen in Container"
4. DevContainer builds and starts automatically

### 2. Start Your Services

If you have a `docker-compose.yml` in your project root, it starts automatically. Otherwise:

```bash
# Start your services
dcup  # Alias for docker-compose up -d

# Check running containers
containers  # Shows all running containers
```

### 3. Use Smart Commands

All commands auto-detect the appropriate container:

```bash
# PHP Development
php --version        # Runs in PHP container
composer install     # Runs in PHP container
artisan migrate      # Laravel commands

# Node.js Development
node --version       # Runs in Node container
npm install         # Runs in Node container
yarn build          # Runs in Node container

# Python Development
python --version    # Runs in Python container
pip install        # Runs in Python container

# Database Access
db                 # Auto-connects to MySQL/PostgreSQL/MongoDB

# Docker Compose
dcup              # Start services
dcdown            # Stop services
dclogs            # View logs
dcps              # Show status
```

## Configuration

### Project Configuration (Optional)

Create `.devcontainer-config` in your project root to specify container names:

```bash
# .devcontainer-config

# Specify container names if auto-detection doesn't work
APP_CONTAINER=my-app
NODE_CONTAINER=my-frontend
DB_CONTAINER=my-database

# Database credentials
DB_USER=myuser
DB_PASSWORD=mypass
DB_NAME=mydb

# Skip auto-start
SKIP_COMPOSE_UP=true
```

### Auto-Detection

If no configuration exists, the DevContainer automatically:
1. Scans running containers for common commands (php, node, python, etc.)
2. Creates aliases that route to the correct container
3. Detects database type and connection method

## Sample docker-compose.yml

Your project should have its own `docker-compose.yml`. Here's a Laravel example:

```yaml
version: '3.8'
services:
  app:
    image: php:8.2-fpm
    volumes:
      - .:/var/www/html
    
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: myapp
    ports:
      - "3306:3306"
      
  node:
    image: node:18
    volumes:
      - .:/app
    command: tail -f /dev/null
```

## Supported Frameworks

The DevContainer auto-detects and supports:

### PHP Frameworks
- Laravel (`artisan` commands)
- Symfony (`symfony` console)
- WordPress (WP-CLI if installed)

### Python Frameworks
- Flask
- FastAPI

### JavaScript/Node.js
- React/Vue/Angular
- Next.js/Nuxt.js
- Express.js

### Databases
- MySQL/MariaDB
- PostgreSQL
- MongoDB
- Redis

## Troubleshooting

### Containers not found

```bash
# Check if services are running
dcps

# Start services manually
dcup

# Verify detection
containers  # List all containers
```

### Commands not working

```bash
# Create configuration file
setup_project_config

# Or manually specify container
docker exec -it container-name command
```

### Port forwarding issues

VS Code automatically forwards ports. Check the "Ports" tab in VS Code terminal panel.

### Permission issues

```bash
# Fix file ownership
sudo chown -R $(id -u):$(id -g) .
```

## Advanced Usage

### Custom Aliases

Add to `.devcontainer-config`:

```bash
# Custom aliases
alias test="docker exec -it app php artisan test"
alias fresh="docker exec -it app php artisan migrate:fresh --seed"
```

### Multiple Projects

Each project gets its own isolated Docker daemon. No conflicts between projects.

### CI/CD Integration

The DevContainer can be used in CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Build DevContainer
  run: docker build -t devcontainer .devcontainer/
  
- name: Run tests
  run: docker run devcontainer sh -c "dcup && artisan test"
```

## Claude Code Integration

Claude Code CLI is pre-installed and ready to use for AI-assisted development:

```bash
claude --help           # Show Claude Code help
claude chat             # Start interactive chat
claude edit file.php    # Edit files with AI assistance
```

## Helper Commands

```bash
devhelp              # Show all available commands
setup_project_config # Auto-generate .devcontainer-config
containers           # List running containers
dc                   # Docker Compose shortcut
claude               # Claude Code CLI
```

## Requirements

- Docker Desktop or Docker Engine
- VS Code with Remote-Containers extension
- 4GB+ RAM recommended

## Benefits

1. **Consistency**: Same environment for all developers
2. **Isolation**: No conflicts with host system
3. **Flexibility**: Works with any tech stack
4. **Simplicity**: Auto-detection reduces configuration
5. **Portability**: Easy to share and replicate

## Contributing

Pull requests welcome! The goal is to support more frameworks and improve auto-detection.

## License

MIT License - Use freely in your projects

## Support

- Check troubleshooting section above
- Create an issue on GitHub
- Review sample configurations

## Tips

1. Keep your project's `docker-compose.yml` in the root directory
2. Use consistent container naming for better auto-detection
3. Create `.devcontainer-config` for complex projects
4. VS Code automatically forwards ports - no manual configuration needed
5. All Docker commands work normally inside the DevContainer