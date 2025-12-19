# Local Development with Docker

This guide explains how to run your Jekyll GitHub Pages site locally using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose installed (usually comes with Docker Desktop)

## Quick Start

1. **Build and start the development server:**

   ```bash
   docker-compose up --build
   ```

2. **Access your site:**

   Open your browser and go to: http://localhost:4000

3. **Stop the development server:**

   Press `Ctrl+C` or run:

   ```bash
   docker compose stop
   ```

## Development Workflow

### First Time Setup

```bash
# Build the Docker image and start the container
docker compose up --build
```

### Daily Development

```bash
# Start the existing container
docker compose up
```

### Making Changes

- Edit your Jekyll files (posts, pages, layouts, etc.)
- To see changes, restart the container: `docker compose stop && docker compose up --build`
- The site will be rebuilt with your latest changes

### Working with Dependencies

If you need to add or update gems:

1. **Modify your Gemfile**
2. **Rebuild the container:**

   ```bash
   docker compose stop
   docker compose up --build
   ```

### Useful Commands

```bash
# Run Jekyll commands inside the container
docker compose exec jekyll bundle exec jekyll --help

# Access the container shell
docker compose exec jekyll bash

# View container logs
docker compose logs jekyll

# Rebuild without cache
docker compose build --no-cache
```

## Troubleshooting

### Port Already in Use

If port 4000 is already in use, modify the `docker-compose.yml` file:

```yaml
ports:
  - "4001:4000"  # Change 4000 to 4001 or any available port
```

### File Permission Issues

On Linux/macOS, if you encounter permission issues:

```bash
# Fix ownership of generated files
sudo chown -R $USER:$USER _site/
```

### Manual Refresh Required

File watching is disabled for stability in Docker. To see changes, you'll need to restart the container with `docker compose stop && docker compose up --build`.

## Configuration

The setup uses:

- **Development environment** (`JEKYLL_ENV=development`)
- **LiveReload** for automatic browser refresh
- **File polling** for cross-platform compatibility
- **Volume mounts** to persist your changes

## Notes

- The `_site/` directory is generated inside the container
- Your source files remain on your host machine
- Bundle cache and vendor directory are persisted in Docker volumes for faster rebuilds
