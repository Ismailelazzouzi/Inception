# Developer Documentation

This document provides technical information for developers working on the Inception project.

## Environment Setup from Scratch

### Prerequisites Installation

#### On Debian/Ubuntu:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install additional tools
sudo apt install -y make openssl git
```

### Project Setup

1. **Clone the repository:**
```bash
git clone <repository-url>
cd Inception
```

2. **Create data directories:**
```bash
sudo mkdir -p /home/isel-azz/data/mariadb
sudo mkdir -p /home/isel-azz/data/wordpress
sudo chmod 755 /home/isel-azz/data
```

3. **Configure environment variables:**

Create `srcs/.env`:
```bash
nano srcs/.env
```

Required variables:
```env
# Domain
DOMAIN_NAME=isel-azz.42.fr

# Database
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress_db
MYSQL_USER=your_db_user
MYSQL_PASSWORD=your_db_password

# WordPress Admin
WP_ADMIN_USER=admin_username     # Cannot contain 'admin'
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com
WP_TITLE=Site Title
WP_URL=https://isel-azz.42.fr

# WordPress User
WP_USER=regular_user
WP_USER_EMAIL=user@example.com
WP_USER_PASSWORD=user_password
```

4. **Create secrets directory:**
```bash
mkdir -p secrets
echo "your_root_password" > secrets/db_root_password.txt
echo "your_db_password" > secrets/db_password.txt
echo "your_db_user" > secrets/credentials.txt
chmod 600 secrets/*
```

5. **Generate SSL certificates:**
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout srcs/requirements/nginx/tools/nginx.key \
    -out srcs/requirements/nginx/tools/nginx.crt \
    -subj "/C=MA/ST=Casablanca/L=Casablanca/O=42/OU=42/CN=isel-azz.42.fr"
```

6. **Configure local DNS:**
```bash
sudo nano /etc/hosts
# Add: 127.0.0.1    isel-azz.42.fr
```

7. **Build and launch:**
```bash
make
```

## Building and Launching

### Using Makefile

The Makefile provides convenient commands:

```bash
# Build and start all services
make

# Stop and remove containers
make down

# Rebuild everything
make re

# Complete cleanup (removes data!)
make fclean

# View logs
make logs

# Check status
make status
```

### Using Docker Compose Directly

```bash
# Build and start in foreground
docker-compose -f srcs/docker-compose.yml up --build

# Build and start in background
docker-compose -f srcs/docker-compose.yml up -d --build

# Stop services
docker-compose -f srcs/docker-compose.yml down

# View logs
docker-compose -f srcs/docker-compose.yml logs -f

# Rebuild specific service
docker-compose -f srcs/docker-compose.yml up -d --build nginx
```

## Container Management Commands

### Building Images

```bash
# Build all images
docker-compose -f srcs/docker-compose.yml build

# Build specific service
docker-compose -f srcs/docker-compose.yml build mariadb

# Build without cache
docker-compose -f srcs/docker-compose.yml build --no-cache
```

### Starting and Stopping

```bash
# Start all containers
docker-compose -f srcs/docker-compose.yml start

# Stop all containers
docker-compose -f srcs/docker-compose.yml stop

# Restart specific service
docker-compose -f srcs/docker-compose.yml restart wordpress
```

### Inspecting Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs mariadb
docker logs -f wordpress  # Follow logs

# Execute command in container
docker exec -it nginx bash
docker exec -it mariadb mysql -u root -p

# Inspect container details
docker inspect mariadb

# View container resource usage
docker stats
```

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect srcs_mariadb_data

# Remove unused volumes
docker volume prune

# Remove specific volume (container must be stopped)
docker volume rm srcs_mariadb_data
```

### Network Management

```bash
# List networks
docker network ls

# Inspect network
docker network inspect srcs_inception_network

# Test connectivity between containers
docker exec wordpress ping mariadb
docker exec nginx ping wordpress
```

## Data Persistence

### Volume Configuration

Data is stored in bind-mounted volumes:

**MariaDB data:**
- Container path: `/var/lib/mysql`
- Host path: `/home/isel-azz/data/mariadb`
- Contains: Database files, tables, indexes

**WordPress data:**
- Container path: `/var/www/html`
- Host path: `/home/isel-azz/data/wordpress`
- Contains: WordPress core, themes, plugins, uploads

### Accessing Persistent Data

```bash
# View MariaDB data
sudo ls -la /home/isel-azz/data/mariadb/

# View WordPress files
ls -la /home/isel-azz/data/wordpress/

# Check disk usage
du -sh /home/isel-azz/data/*
```

### Backup Strategy

```bash
# Backup script example
#!/bin/bash
BACKUP_DIR=~/inception-backups
DATE=$(date +%Y%m%d_%H%M%S)

# Stop services
make down

# Create backups
sudo tar -czf $BACKUP_DIR/mariadb-$DATE.tar.gz /home/isel-azz/data/mariadb
sudo tar -czf $BACKUP_DIR/wordpress-$DATE.tar.gz /home/isel-azz/data/wordpress

# Restart services
make
```

## Service Architecture

### Service Dependencies

```
NGINX (port 443)
  ↓ depends_on
WordPress (port 9000)
  ↓ depends_on
MariaDB (port 3306)
```

All services connect through the `inception_network` bridge network.

### Inter-Service Communication

Services communicate using Docker's internal DNS:

```bash
# NGINX → WordPress
fastcgi_pass wordpress:9000;

# WordPress → MariaDB
--dbhost="mariadb:3306"
```

### Health Checks

Each service has a health check:

**MariaDB:**
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s
  timeout: 5s
  retries: 5
```

**WordPress:**
```yaml
healthcheck:
  test: ["CMD", "php-fpm7.4", "-t"]
  interval: 10s
  timeout: 5s
  retries: 5
```

## Debugging

### Common Issues and Solutions

#### Container Won't Start

```bash
# View detailed logs
docker logs container_name

# Check if port is already in use
sudo netstat -tulpn | grep 443

# Inspect container configuration
docker inspect container_name
```

#### Permission Errors

```bash
# Fix data directory permissions
sudo chown -R isel-azz:isel-azz /home/isel-azz/data/

# Fix container file permissions
docker exec -it wordpress chown -R www-data:www-data /var/www/html
```

#### Network Issues

```bash
# Test network connectivity
docker exec wordpress ping mariadb
docker exec nginx ping wordpress

# Inspect network
docker network inspect srcs_inception_network

# Recreate network
docker network rm srcs_inception_network
make
```

#### Database Connection Issues

```bash
# Test MariaDB from host
docker exec -it mariadb mysql -u samael -p

# Test from WordPress container
docker exec -it wordpress mysql -h mariadb -u samael -p

# Check MariaDB logs
docker logs mariadb
```

### Development Workflow

1. **Make changes to Dockerfile or scripts**
```bash
nano srcs/requirements/nginx/Dockerfile
```

2. **Rebuild specific service**
```bash
docker-compose -f srcs/docker-compose.yml up -d --build nginx
```

3. **Test changes**
```bash
docker logs -f nginx
curl -k https://isel-azz.42.fr
```

4. **If issues occur, check logs and rebuild**
```bash
docker-compose -f srcs/docker-compose.yml down
docker-compose -f srcs/docker-compose.yml up --build
```

## Dockerfile Best Practices

### Layer Optimization

Combine related RUN commands to reduce layers:

```dockerfile
# Instead of multiple RUN commands:
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2

# Use one RUN command:
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*
```

### Security Best Practices

- Use specific base image versions (e.g., `debian:bullseye`)
- Don't run containers as root
- Clean up apt cache after installation
- Don't store credentials in Dockerfiles
- Use `.dockerignore` files

### Image Optimization

- Minimize layers by combining commands
- Remove unnecessary files
- Use multi-stage builds when appropriate
- Keep images focused and small

## Docker Compose Best Practices

- Use explicit dependencies with `depends_on` and health checks
- Define explicit networks
- Name containers explicitly
- Use environment files for configuration
- Define restart policies
- Use volumes for persistent data

## Testing

### Manual Testing

```bash
# Test MariaDB
docker exec -it mariadb mysql -u samael -p -e "SHOW DATABASES;"

# Test WordPress CLI
docker exec -it wordpress wp --info --allow-root

# Test NGINX configuration
docker exec -it nginx nginx -t

# Test SSL certificate
openssl s_client -connect isel-azz.42.fr:443 -servername isel-azz.42.fr
```

### Automated Testing Script

```bash
#!/bin/bash

echo "Testing Inception infrastructure..."

# Test containers are running
if [ $(docker ps | grep -c "mariadb\|wordpress\|nginx") -eq 3 ]; then
    echo "✓ All containers running"
else
    echo "✗ Not all containers running"
    exit 1
fi

# Test database
if docker exec mariadb mysqladmin ping &>/dev/null; then
    echo "✓ MariaDB responding"
else
    echo "✗ MariaDB not responding"
    exit 1
fi

# Test website
if curl -k https://isel-azz.42.fr &>/dev/null; then
    echo "✓ Website accessible"
else
    echo "✗ Website not accessible"
    exit 1
fi

echo "All tests passed!"
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
