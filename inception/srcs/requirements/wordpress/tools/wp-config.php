<?php
/**
 * WordPress Configuration File
 */

// ** Database settings - You can get this info from your web host ** //
define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_HOST', 'mariadb:3306');  // Use the service name from docker-compose
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// ** Authentication unique keys and salts ** //
define('AUTH_KEY',         '${WP_AUTH_KEY}');
define('SECURE_AUTH_KEY',  '${WP_SECURE_AUTH_KEY}');
define('LOGGED_IN_KEY',    '${WP_LOGGED_IN_KEY}');
define('NONCE_KEY',        '${WP_NONCE_KEY}');
define('AUTH_SALT',        '${WP_AUTH_SALT}');
define('SECURE_AUTH_SALT', '${WP_SECURE_AUTH_SALT}');
define('LOGGED_IN_SALT',   '${WP_LOGGED_IN_SALT}');
define('NONCE_SALT',       '${WP_NONCE_SALT}');

// ** WordPress Database Table prefix ** //
$table_prefix = 'wp_';

// ** Debug mode ** //
define('WP_DEBUG', false);

// Sets up WordPress vars and included files
if (!defined('ABSPATH'))
    define('ABSPATH', dirname(__FILE__) . '/');

require_once ABSPATH . 'wp-settings.php';
