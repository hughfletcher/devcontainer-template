# Laravel DevContainer Configuration

This folder contains Laravel-specific configuration for your DevContainer environment.

## Quick Start

1. **Copy the entire `.devcontainer/` folder** to your Laravel project root
2. **Add to your project's `.env` file:**
   ```bash
   DEVCONTAINER_FRAMEWORK=laravel
   ```
3. **Open in VS Code** and reopen in container

## What's Included

### Sample Docker Compose Stack
- **`sample-docker-compose.yml`** - Full Laravel development stack:
  - Apache + PHP 8.3 application container
  - Node.js 20 for Vite/frontend
  - MySQL 8.0 (with named volume)
  - PostgreSQL 15 (with named volume) - comment out if not needed
  - Redis 7 for caching/queues
  - Mailhog for email testing
  - Playwright for browser testing (profile: `testing`)

### Laravel-Specific Bash Helpers
Auto-loaded when `DEVCONTAINER_FRAMEWORK=laravel` is set:

#### Laravel Commands
- `artisan [args]` - Run Laravel artisan commands in app container
- `php [args]` - Run PHP in app container
- `composer [args]` - Run Composer in app container

#### Frontend Commands
- `node [args]` - Run Node.js in node container
- `npm [args]` - Run npm in node container

#### Database
- `db` - Auto-connect to database (detects MySQL/PostgreSQL)

#### Docker Shortcuts
- `dcup` - Start containers (`docker-compose up -d`)
- `dcdown` - Stop containers
- `dcrestart` - Restart containers
- `dclogs` - View logs
- `dcps` - List containers

#### Testing
- `test [args]` - Run tests (auto-detects Pest or PHPUnit)

## Setup Instructions

### 1. Use the Sample Docker Compose (Optional)

If you don't have a docker-compose.yml yet:

```bash
cp .devcontainer/laravel/sample-docker-compose.yml docker-compose.yml
```

**Note:** You'll need to create `docker/app/Dockerfile` for the PHP+Apache container. See below.

### 2. Create PHP Application Dockerfile

Create `docker/app/Dockerfile`:

```dockerfile
FROM php:8.3-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Configure Apache DocumentRoot
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set permissions
RUN chown -R www-data:www-data /var/www/html
```

### 3. Configure Your Laravel .env

Update your project's `.env`:

```bash
# DevContainer Framework
DEVCONTAINER_FRAMEWORK=laravel

# DevContainer Options
# SKIP_COMPOSE_UP=true  # Uncomment to prevent auto-starting containers on devcontainer start

# Database (choose one)
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=password

# OR for PostgreSQL:
# DB_CONNECTION=pgsql
# DB_HOST=postgres
# DB_PORT=5432

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Mail (Mailhog)
MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_ENCRYPTION=null

# Docker Compose Ports
APP_PORT=8080
VITE_PORT=5173
```

### 4. Customize the Stack (Optional)

**Using only MySQL?** Comment out the postgres service in docker-compose.yml and remove from `depends_on`.

**Using only PostgreSQL?** Comment out the mysql service.

**Don't need Playwright?** It's already in a `testing` profile, so it won't start by default. To start it:
```bash
docker-compose --profile testing up -d
```

## Usage

### Starting Your Environment

```bash
# In VS Code, open the project and click "Reopen in Container"
# Or use the command palette: "Dev Containers: Reopen in Container"

# Once inside, start your stack:
dcup

# Check running containers:
dcps

# View logs:
dclogs
```

### Common Laravel Tasks

```bash
# Run migrations
artisan migrate

# Seed database
artisan db:seed

# Clear cache
artisan cache:clear

# Run tests
test

# Install PHP dependencies
composer install

# Install frontend dependencies
npm install

# Run Vite dev server (already running in node container)
# Access at http://localhost:5173
```

### Database Access

```bash
# Quick connect (auto-detects MySQL or PostgreSQL)
db

# Or use your favorite database client:
# MySQL: localhost:3306
# PostgreSQL: localhost:5432
```

### Email Testing

Mailhog captures all emails sent by your application:
- Web UI: http://localhost:8025

## Troubleshooting

### Containers not starting?
```bash
# Check Docker daemon
docker info

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Commands not found?
Make sure `DEVCONTAINER_FRAMEWORK=laravel` is in your `.env` file and restart your terminal.

### Permission issues?
```bash
# Fix Laravel storage permissions
docker exec -it myapp-app chown -R www-data:www-data storage bootstrap/cache
```

## Adding More Frameworks

You can create additional framework folders alongside `laravel/`:

```
.devcontainer/
  ├── laravel/
  ├── django/
  ├── nextjs/
  └── ...
```

Each with its own `.bashrc` and `sample-docker-compose.yml`. Switch between them by changing `DEVCONTAINER_FRAMEWORK` in your `.env`.

## Questions?

- Check the main README: `../.devcontainer/README.md`
- Or run `devhelp` in your terminal for available commands
