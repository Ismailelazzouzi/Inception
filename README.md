*This project has been created as part of the 42 curriculum by isel-azz.*

# Inception

## Description

Inception is a system administration project focused on Docker containerization. The project involves setting up a small infrastructure composed of different services using Docker and Docker Compose. The infrastructure includes:

- **NGINX**: Web server configured with TLSv1.2/TLSv1.3 for secure HTTPS connections
- **WordPress**: Content management system with PHP-FPM
- **MariaDB**: Relational database management system

All services run in separate Docker containers, connected through a dedicated Docker network, with data persisted in volumes.

### Key Features

- Secure HTTPS-only access through NGINX (port 443)
- Isolated containerized services
- Persistent data storage using Docker volumes
- Custom Docker images built from Debian Bullseye
- Environment-based configuration management
- Automated setup using Makefile

### Goals

This project aims to deepen understanding of:
- Docker containerization and orchestration
- System administration principles
- Network configuration and security
- Service isolation and communication
- Infrastructure as Code practices

## Instructions

### Prerequisites

- Docker Engine (version 20.10+)
- Docker Compose (version 1.29+)
- Make
- OpenSSL (for SSL certificate generation)
- Sudo privileges (for data directory management)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Inception
```

2. Configure environment variables:
```bash
# Edit srcs/.env with your credentials
nano srcs/.env
```

3. Add domain to /etc/hosts:
```bash
sudo nano /etc/hosts
# Add: 127.0.0.1    isel-azz.42.fr
```

4. Build and start:
```bash
make
```

### Usage

**Start the infrastructure:**
```bash
make up
```

**Stop the infrastructure:**
```bash
make down
```

**View logs:**
```bash
make logs
```

**Rebuild everything:**
```bash
make re
```

**Full cleanup:**
```bash
make fclean
```

### Accessing Services

- **WordPress Site**: https://isel-azz.42.fr
- **WordPress Admin**: https://isel-azz.42.fr/wp-admin
  - Username: `isel_azz`
  - Password: (configured in .env)

## Project Structure

```
Inception/
├── Makefile                    # Build automation
├── secrets/                    # Sensitive credentials (gitignored)
│   ├── db_root_password.txt
│   ├── db_password.txt
│   └── credentials.txt
└── srcs/
    ├── docker-compose.yml      # Service orchestration
    ├── .env                    # Environment variables (gitignored)
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── init-db.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── setup-wordpress.sh
        └── nginx/
            ├── Dockerfile
            ├── conf/
            │   └── nginx.conf
            └── tools/
                ├── nginx.crt
                └── nginx.key
```

## Technical Comparisons

### Virtual Machines vs Docker

**Virtual Machines:**
- Full OS isolation with hypervisor
- Higher resource overhead (RAM, CPU, storage)
- Slower startup times (minutes)
- Better security isolation
- Ideal for running different OS types

**Docker:**
- Container-level isolation sharing host kernel
- Minimal resource overhead
- Fast startup times (seconds)
- Lighter weight and more portable
- Ideal for microservices architecture

**Inception's Choice**: Docker was chosen for its efficiency, portability, and alignment with modern DevOps practices.

### Secrets vs Environment Variables

**Environment Variables:**
- Simple key-value configuration
- Easy to manage and inject
- Visible in process listings and logs
- Suitable for non-sensitive configuration

**Docker Secrets:**
- Encrypted at rest and in transit
- Only available to authorized services
- Not exposed in logs or process listings
- Requires Docker Swarm mode

**Inception's Approach**: Uses `.env` files with proper `.gitignore` configuration. For production environments, Docker Secrets would be the preferred method for managing credentials.

### Docker Network vs Host Network

**Docker Network (Bridge):**
- Isolated network namespace
- Service-to-service communication via service names
- Port mapping required for external access
- Better security through isolation

**Host Network:**
- Shares host's network stack
- Direct access to all ports
- Less isolation, potential conflicts
- Slightly better performance

**Inception's Choice**: Bridge network provides proper isolation while allowing controlled external access through NGINX on port 443.

### Docker Volumes vs Bind Mounts

**Docker Volumes:**
- Managed by Docker
- Portable across different hosts
- Automatic backup and migration support
- Better performance on non-Linux hosts

**Bind Mounts:**
- Direct host filesystem access
- Specific host path dependency
- Easier for development and inspection
- Full control over file location

**Inception's Approach**: Uses bind mounts to `/home/login/data` as specified in subject requirements, allowing direct data access and inspection.

## Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)

### Tutorials
- [Docker Curriculum](https://docker-curriculum.com/)
- [NGINX Beginner's Guide](http://nginx.org/en/docs/beginners_guide.html)
- [WordPress Installation Guide](https://wordpress.org/support/article/how-to-install-wordpress/)

### AI Usage

AI tools (Claude) were used in this project for:

**Learning and Understanding:**
- Explaining Docker concepts and best practices
- Understanding service dependencies and orchestration
- Learning about network isolation and security principles
- Understanding the differences between various Docker features

**Problem Solving:**
- Debugging container startup issues and permission problems
- Troubleshooting network connectivity between containers
- Resolving configuration syntax errors
- Optimizing Dockerfile layer structure

**Code Review and Optimization:**
- Reviewing Dockerfiles for best practices
- Suggesting improvements for script efficiency
- Identifying potential security issues
- Optimizing build process and reducing image sizes

**Documentation:**
- Structuring comprehensive documentation
- Explaining technical concepts clearly
- Creating evaluation preparation materials
- Generating code comments and explanations

**Approach:**
All AI-generated content was thoroughly reviewed, tested, and understood before implementation. The AI served as a learning tool and reference, similar to documentation or Stack Overflow, but all final decisions and implementations were made with full understanding of their purpose and functionality. The core learning objectives of Docker containerization, system administration, and infrastructure setup were achieved through hands-on implementation, debugging, and iterative improvement.

**Key Principle:**
No AI-generated code was used without complete understanding. Every line of configuration, every script, and every Docker command was studied, tested, and could be explained in detail during evaluation.
