#!/bin/bash
set -e
echo "Starting WordPress setup..."
echo "Waiting for MariaDB to be ready..."
until mysqladmin ping -h"mariadb" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
    echo "MariaDB is unavailable - sleeping"
    sleep 2
done
echo "MariaDB is up!"
cd /var/www/html
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
    
    echo "Installing WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
    
    echo "Creating additional WordPress user..."
    if ! wp user get "${WP_USER}" --allow-root > /dev/null 2>&1; then
        wp user create \
            "${WP_USER}" \
            "${WP_USER_EMAIL}" \
            --role=author \
            --user_pass="${WP_USER_PASSWORD}" \
            --allow-root
        echo "User ${WP_USER} created successfully."
    else
        echo "User ${WP_USER} already exists, skipping creation."
    fi
    
    echo "WordPress installation complete!"
else
    echo "WordPress already installed!"
fi
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
mkdir -p /run/php
chown www-data:www-data /run/php
echo "Starting PHP-FPM..."
exec php-fpm7.4 -F