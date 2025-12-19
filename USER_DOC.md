# User Documentation

This document explains how to use and manage the Inception WordPress infrastructure.

## Services Provided

The Inception stack provides the following services:

1. **WordPress Website**
   - Full-featured content management system
   - Blog and page creation
   - Media management
   - Theme and plugin support

2. **HTTPS Web Server**
   - Secure access via NGINX
   - TLS 1.2/1.3 encryption
   - Static file serving
   - PHP request handling

3. **Database System**
   - MariaDB relational database
   - Data persistence
   - Automatic backups through volumes

## Starting and Stopping the Project

### Starting the Infrastructure

To start all services:

```bash
cd /path/to/Inception
make
```

This will:
- Create necessary data directories
- Build Docker images
- Start all containers
- Make the site available at https://isel-azz.42.fr

**First-time startup** may take 2-3 minutes as Docker downloads base images and builds containers.

### Stopping the Infrastructure

To stop all services:

```bash
make down
```

This will:
- Stop all running containers
- Remove containers
- Keep your data intact in volumes

### Restarting Services

To restart without rebuilding:

```bash
make stop    # Stop containers
make start   # Start containers again
```

To rebuild and restart everything:

```bash
make re
```

## Accessing the Website

### Main Website

Open your web browser and navigate to:
```
https://isel-azz.42.fr
```

**Note**: You'll see a security warning because the SSL certificate is self-signed. Click "Advanced" → "Accept Risk and Continue" (Firefox) or "Advanced" → "Proceed" (Chrome).

### Administration Panel

To manage your WordPress site:

1. Go to: `https://isel-azz.42.fr/wp-admin`
2. Enter your credentials:
   - **Username**: `isel_azz` (administrator)
   - **Password**: Configured in `.env` file

From the admin panel you can:
- Create and edit posts/pages
- Manage themes and plugins
- Configure site settings
- Manage users
- View site statistics

## Managing Credentials

### Location of Credentials

Credentials are stored in two places:

1. **Main configuration**: `srcs/.env`
   - Database credentials
   - WordPress admin credentials
   - Domain configuration

2. **Secrets directory**: `secrets/`
   - `db_root_password.txt` - MariaDB root password
   - `db_password.txt` - WordPress database user password
   - `credentials.txt` - Additional credentials

### Viewing Current Credentials

To see your WordPress admin credentials:

```bash
cat srcs/.env | grep WP_ADMIN
```

### Changing Credentials

**Important**: Changing credentials requires rebuilding the infrastructure.

1. Stop all services:
```bash
make down
```

2. Edit the `.env` file:
```bash
nano srcs/.env
```

3. Update the desired passwords:
```env
MYSQL_PASSWORD=new_password_here
WP_ADMIN_PASSWORD=new_admin_password
```

4. Clean and rebuild:
```bash
make fclean
make
```

**Warning**: `make fclean` will delete all data! Back up your content first.

## Checking Service Status

### View All Running Containers

```bash
make status
```

Expected output:
```
NAME        STATUS                  PORTS
nginx       Up (healthy)           0.0.0.0:443->443/tcp
wordpress   Up (healthy)           9000/tcp
mariadb     Up (healthy)           3306/tcp
```

### View Service Logs

To see real-time logs from all services:

```bash
make logs
```

Press `Ctrl+C` to exit log viewing.

### Check Individual Container

```bash
docker ps
```

Look for:
- **STATUS**: Should show "Up" and "(healthy)"
- **PORTS**: Verify correct port mappings

### Test Database Connection

```bash
docker exec -it mariadb mysql -u samael -p
```

Enter your database password when prompted.

### Test WordPress Installation

```bash
docker exec -it wordpress wp core version --allow-root
```

This shows the installed WordPress version.

## Common Tasks

### Viewing Website Logs

```bash
docker exec -it nginx tail -f /var/log/nginx/access.log
docker exec -it nginx tail -f /var/log/nginx/error.log
```

### Backing Up Your Data

Your data is stored in:
- `/home/isel-azz/data/mariadb/` - Database files
- `/home/isel-azz/data/wordpress/` - WordPress files

To create a backup:

```bash
# Create backup directory
mkdir -p ~/inception-backup

# Backup WordPress files
sudo tar -czf ~/inception-backup/wordpress-$(date +%Y%m%d).tar.gz /home/isel-azz/data/wordpress/

# Backup database files
sudo tar -czf ~/inception-backup/mariadb-$(date +%Y%m%d).tar.gz /home/isel-azz/data/mariadb/
```

### Restoring from Backup

```bash
# Stop services
make down

# Restore files
sudo tar -xzf ~/inception-backup/wordpress-YYYYMMDD.tar.gz -C /
sudo tar -xzf ~/inception-backup/mariadb-YYYYMMDD.tar.gz -C /

# Restart services
make
```

## Troubleshooting

### Site Not Loading

1. Check if all containers are running:
```bash
make status
```

2. Verify domain in `/etc/hosts`:
```bash
cat /etc/hosts | grep isel-azz.42.fr
```
Should show: `127.0.0.1    isel-azz.42.fr`

3. Check NGINX logs:
```bash
docker logs nginx
```

### "502 Bad Gateway" Error

This means NGINX can't connect to WordPress.

1. Check WordPress container health:
```bash
docker ps | grep wordpress
```

2. View WordPress logs:
```bash
docker logs wordpress
```

3. Restart services:
```bash
make stop
make start
```

### Database Connection Error

1. Check MariaDB status:
```bash
docker ps | grep mariadb
```

2. Test database connection:
```bash
docker exec -it mariadb mysqladmin ping
```

3. View MariaDB logs:
```bash
docker logs mariadb
```

### Complete Reset

If nothing works, perform a complete reset:

```bash
make fclean  # WARNING: Deletes all data!
make
```

## Security Notes

- **HTTPS Only**: The site only accepts HTTPS connections on port 443
- **Self-Signed Certificate**: For production, replace with a proper SSL certificate
- **Change Default Passwords**: Always use strong, unique passwords
- **Regular Backups**: Create backups before making changes
- **Keep Updated**: Regularly update WordPress core, themes, and plugins

## Support

For issues or questions:
1. Check the logs: `make logs`
2. Review documentation: README.md and DEV_DOC.md
3. Consult Docker documentation: https://docs.docker.com/
4. Check WordPress documentation: https://wordpress.org/support/
