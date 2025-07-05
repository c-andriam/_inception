#!/bin/sh
set -e

echo "Starting WordPress container..."
echo "Domain: $DOMAIN_NAME"
echo "Database: $MYSQL_DATABASE"
echo "Database User: $MYSQL_USER"

# Créer un lien symbolique vers la bonne version de PHP
if [ -e /usr/bin/php82 ] && [ ! -e /usr/bin/php ]; then
    ln -sf /usr/bin/php82 /usr/bin/php
    echo "Created symlink from php82 to php"
fi

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until mysqladmin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    echo "Waiting for MariaDB... (will retry in 5 seconds)"
    sleep 5
done
echo "MariaDB is ready!"

# Générer wp-config.php si nécessaire
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Generating WordPress configuration file..."
    
    # Générer le fichier wp-config.php directement
    cat > /var/www/html/wp-config.php << EOF
<?php
/**
 * WordPress Configuration File
 */

// ** Database settings - You can get this info from your web host ** //
define('DB_NAME', '$MYSQL_DATABASE');
define('DB_USER', '$MYSQL_USER');
define('DB_PASSWORD', '$MYSQL_PASSWORD');
define('DB_HOST', 'mariadb');  // Use the service name from docker-compose
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// ** Authentication unique keys and salts ** //
define('AUTH_KEY',         '$WP_AUTH_KEY');
define('SECURE_AUTH_KEY',  '$WP_SECURE_AUTH_KEY');
define('LOGGED_IN_KEY',    '$WP_LOGGED_IN_KEY');
define('NONCE_KEY',        '$WP_NONCE_KEY');
define('AUTH_SALT',        '$WP_AUTH_SALT');
define('SECURE_AUTH_SALT', '$WP_SECURE_AUTH_SALT');
define('LOGGED_IN_SALT',   '$WP_LOGGED_IN_SALT');
define('NONCE_SALT',       '$WP_NONCE_SALT');

// ** WordPress Database Table prefix ** //
\$table_prefix = 'wp_';

// ** Debug mode ** //
define('WP_DEBUG', false);

// ** Filesystem method ** //
define('FS_METHOD', 'direct');

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
EOF
fi

# Installer WP-CLI si nécessaire
if [ ! -f "/usr/local/bin/wp" ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Installer WordPress uniquement s'il n'est pas déjà installé
cd /var/www/html
if ! php82 /usr/local/bin/wp core is-installed --allow-root; then
    echo "WordPress not installed. Setting up..."
    echo "Installing WordPress core..."
    php82 /usr/local/bin/wp core install --url=https://${DOMAIN_NAME} --title="Inception" \
        --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} --skip-email --allow-root
    
    # Créer l'utilisateur uniquement s'il n'existe pas déjà
    if ! php82 /usr/local/bin/wp user get ${WP_USER} --allow-root &>/dev/null; then
        echo "Creating additional WordPress user..."
        php82 /usr/local/bin/wp user create ${WP_USER} ${WP_EMAIL} --role=author --user_pass=${WP_PASSWORD} --allow-root
    fi
    
    echo "WordPress setup complete!"
fi

echo "WordPress configuration complete. Starting PHP-FPM..."

# IMPORTANT: Utiliser exec pour remplacer le shell par le processus PHP-FPM
# et permettre aux signaux d'être correctement transmis
exec /usr/sbin/php-fpm82 -F --nodaemonize
