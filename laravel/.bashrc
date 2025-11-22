#!/bin/bash
# Laravel-Specific DevContainer Configuration
# This file is auto-sourced when DEVCONTAINER_FRAMEWORK=laravel in project .env

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}Laravel development environment loaded!${NC}"

# Get database connection from .env
DB_CONNECTION="mysql"
if [ -f "/workspace/.env" ]; then
    ENV_DB_CONNECTION=$(grep -E "^DB_CONNECTION=" /workspace/.env 2>/dev/null | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    if [ -n "$ENV_DB_CONNECTION" ]; then
        DB_CONNECTION="$ENV_DB_CONNECTION"
    fi
fi

# Laravel Artisan Command
artisan() {
    docker-compose exec app php artisan "$@"
}

# PHP Command
php() {
    docker-compose exec app php "$@"
}

# Composer Command
composer() {
    docker-compose exec app composer "$@"
}

# Node/NPM Commands
node() {
    docker-compose exec node node "$@"
}

npm() {
    docker-compose exec node npm "$@"
}

# Database Connection
db() {
    if [ "$DB_CONNECTION" = "mysql" ]; then
        docker-compose exec mysql mysql -u${DB_USERNAME:-laravel} -p${DB_PASSWORD:-password} ${DB_DATABASE:-laravel}
    elif [ "$DB_CONNECTION" = "pgsql" ]; then
        docker-compose exec postgres psql -U ${DB_USERNAME:-laravel} ${DB_DATABASE:-laravel}
    else
        echo -e "${RED}Unknown DB_CONNECTION: $DB_CONNECTION${NC}"
        echo "Set DB_CONNECTION to 'mysql' or 'pgsql' in your .env file"
        return 1
    fi
}

# Docker Compose Shortcuts
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcrestart='docker-compose restart'
alias dclogs='docker-compose logs -f'
alias dcps='docker-compose ps'

# Testing Commands (PHPUnit/Pest)
test() {
    docker-compose exec app bash -c '
        if [ -f vendor/bin/pest ]; then
            ./vendor/bin/pest "$@"
        elif [ -f vendor/bin/phpunit ]; then
            ./vendor/bin/phpunit "$@"
        else
            echo "No test framework found. Run: composer require --dev pestphp/pest"
            exit 1
        fi
    ' -- "$@"
}

# Laravel-specific help
devhelp() {
    echo -e "${GREEN}=== Laravel DevContainer Commands ===${NC}"
    echo ""
    echo -e "${CYAN}Laravel:${NC}"
    echo "  artisan              - Run Laravel artisan commands"
    echo "  php                  - Run PHP in app container"
    echo "  composer             - Run Composer in app container"
    echo ""
    echo -e "${CYAN}Frontend:${NC}"
    echo "  node                 - Run Node.js in node container"
    echo "  npm                  - Run npm in node container"
    echo ""
    echo -e "${CYAN}Database (${DB_CONNECTION}):${NC}"
    echo "  db                   - Connect to database"
    echo ""
    echo -e "${CYAN}Docker:${NC}"
    echo "  dcup                 - Start containers"
    echo "  dcdown               - Stop containers"
    echo "  dcrestart            - Restart containers"
    echo "  dclogs               - View container logs"
    echo "  dcps                 - List running containers"
    echo ""
    echo -e "${CYAN}Testing:${NC}"
    echo "  test [args]          - Run Pest or PHPUnit tests"
    echo ""
    echo -e "${CYAN}Service Names:${NC}"
    echo "  app       - Apache + PHP 8.3"
    echo "  node      - Node.js 20"
    echo "  mysql     - MySQL 8.0 (comment out if using postgres)"
    echo "  postgres  - PostgreSQL 15 (comment out if using mysql)"
    echo "  redis     - Redis 7"
    echo "  mailhog   - Email testing (UI: http://localhost:8025)"
}

echo "Type 'devhelp' for available commands"
