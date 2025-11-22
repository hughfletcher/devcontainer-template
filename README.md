# Universal DevContainer Template

A modular, framework-specific DevContainer that provides an isolated Docker-in-Docker environment for development projects. Choose your framework (Laravel, Django, Next.js, etc.) and get pre-configured commands and tooling.

## Key Features

- **Framework-Specific Modules**: Load Laravel, Django, or other framework helpers on demand
- **Claude Code Integrated**: AI-assisted development out of the box
- **Docker-in-Docker**: Complete isolation with nested container support
- **VS Code Integration**: Full Remote-Containers support with port forwarding
- **Simple Configuration**: One environment variable to enable framework features

## Quick Start

### 1. Copy to Your Project

```bash
# Copy this entire folder to your project as .devcontainer/
cp -r devcontainer-template /path/to/your-project/.devcontainer
```

### 2. Enable Framework Helpers (Optional)

Add to your project's `.env` file:

```bash
DEVCONTAINER_FRAMEWORK=laravel
```

Available frameworks:
- `laravel` - Laravel-specific commands (artisan, composer, test, etc.)
- More coming soon (django, nextjs, rails, etc.)

### 3. Open in VS Code

1. Install "Dev Containers" extension
2. Open your project folder
3. Press `F1` → "Dev Containers: Reopen in Container"

## Architecture

```
DevContainer (Ubuntu + Docker-in-Docker + Claude Code)
  └── Your Project's Docker Compose Stack
      ├── App Container (PHP/Node/Python)
      ├── Database (MySQL/PostgreSQL)
      └── Other Services (Redis, Mailhog, etc.)
```

## Usage

### Without Framework (Generic Mode)

Basic Docker Compose shortcuts are always available:

```bash
dcup              # Start containers (docker-compose up -d)
dcdown            # Stop containers
dclogs            # View logs
dcps              # Show running containers
containers        # List all containers
claude            # Claude Code CLI
devhelp           # Show available commands
```

### With Framework (Laravel Example)

When `DEVCONTAINER_FRAMEWORK=laravel` is set in your `.env`:

```bash
# Laravel
artisan migrate           # Run artisan commands
php --version            # Run PHP in app container
composer install         # Run Composer

# Frontend
npm install              # Run npm in node container
node --version          # Run Node.js

# Database
db                       # Connect to database (mysql/postgres)

# Testing
test                     # Run Pest or PHPUnit

# All generic commands still work
dcup, dcdown, claude, etc.
```

See `laravel/README.md` for complete Laravel setup guide.

## Framework Folders

Each framework has its own folder with:
- `.bashrc` - Framework-specific bash commands
- `sample-docker-compose.yml` - Reference Docker Compose stack
- `README.md` - Complete setup and usage guide

```
.devcontainer/
  ├── .bashrc              # Base config (framework loader)
  ├── Dockerfile           # Base image
  ├── devcontainer.json    # VS Code config
  ├── laravel/             # Laravel framework
  │   ├── .bashrc
  │   ├── sample-docker-compose.yml
  │   └── README.md
  └── (future: django/, nextjs/, rails/, etc.)
```

## Laravel Setup Example

1. **Copy devcontainer:**
   ```bash
   cp -r devcontainer-template /path/to/laravel-project/.devcontainer
   ```

2. **Add to project `.env`:**
   ```bash
   DEVCONTAINER_FRAMEWORK=laravel
   DB_CONNECTION=mysql
   DB_DATABASE=laravel
   DB_USERNAME=laravel
   DB_PASSWORD=password
   ```

3. **Copy sample docker-compose (optional):**
   ```bash
   cp .devcontainer/laravel/sample-docker-compose.yml docker-compose.yml
   ```

4. **Open in VS Code** and start coding!

## Claude Code Integration

Claude Code CLI and Monitor are pre-installed with optimized defaults:

```bash
claude              # Claude Code (with --dangerously-skip-permissions)
claude chat         # Start interactive chat
claude edit file.php # AI-assisted editing

claude-monitor      # Monitor Claude Code usage
cm                  # Alias for claude-monitor
```

### MCP Servers

The following MCP servers are pre-installed and configured:

- **@upstash/context7** - Automatic context management for Claude Code

MCP servers are automatically configured during container setup.

## Creating New Framework Modules

Want to add support for Django, Rails, or Next.js?

1. Create a folder: `.devcontainer/django/`
2. Add `.bashrc` with framework commands
3. Add `sample-docker-compose.yml`
4. Add `README.md` with setup instructions

Users can then use: `DEVCONTAINER_FRAMEWORK=django`

## Requirements

- Docker Desktop or Docker Engine
- VS Code with Dev Containers extension
- 4GB+ RAM recommended

## Shared Resources

This devcontainer uses shared host folders for persistence across all projects:

- `~/.devcontainer-shared/docker` - Docker images (shared across all devcontainers)
- `~/.devcontainer-shared/claude` - Claude authentication (login once, use everywhere)
- `~/.devcontainer-shared/composer` - Composer cache (faster PHP installs)

**Benefits:**
- Download Docker images once, use in all projects
- Authenticate with Claude Code once, works in all projects
- Faster rebuilds and container starts

## Benefits

1. **Modular**: Only load what you need
2. **Consistent**: Same environment for all developers
3. **Isolated**: No conflicts with host system
4. **Extensible**: Easy to add new frameworks
5. **AI-Ready**: Claude Code integration out of the box

## Troubleshooting

### Framework not loading?

Check your `.env` file has:
```bash
DEVCONTAINER_FRAMEWORK=laravel
```

Restart terminal or run: `source ~/.bashrc`

### Containers not starting?

```bash
dcps              # Check container status
dclogs            # View logs
docker-compose up # Manual start
```

### Commands not found?

Make sure containers are running:
```bash
dcup              # Start containers
dcps              # Verify they're running
```

### Port forwarding issues

VS Code automatically forwards ports. Check the "Ports" tab in the terminal panel.

## Helper Commands

```bash
devhelp           # Show all available commands
claude            # Claude Code CLI
claude-monitor, cm # Claude Monitor (usage tracking)
containers        # List running containers
dcup/dcdown       # Start/stop containers
```

## Tips

1. Always add `DEVCONTAINER_FRAMEWORK` to your project's `.env` file
2. Each framework folder has detailed setup docs in its README.md
3. The base devcontainer is framework-agnostic - you can use it without any framework
4. All framework commands use `docker-compose exec` for simplicity

## Contributing

Want to add a framework? PR's welcome!

1. Create folder: `.devcontainer/yourframework/`
2. Add `.bashrc`, `sample-docker-compose.yml`, `README.md`
3. Submit PR

## License

MIT License - Use freely in your projects
