<?php
/**
 * WordPress Configuration File
 */

// ** Database settings - You can get this info from your web host ** //
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress_user');
define('DB_PASSWORD', 'test');
define('DB_HOST', 'mariadb');  // Use the service name from docker-compose
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// ** Authentication unique keys and salts ** //
define('AUTH_KEY',         'uniquevalue1');
define('SECURE_AUTH_KEY',  'uniquevalue2');
define('LOGGED_IN_KEY',    'uniquevalue3');
define('NONCE_KEY',        'uniquevalue4');
define('AUTH_SALT',        'uniquevalue5');
define('SECURE_AUTH_SALT', 'uniquevalue6');
define('LOGGED_IN_SALT',   'uniquevalue7');
define('NONCE_SALT',       'uniquevalue8');

// ** WordPress Database Table prefix ** //
$table_prefix = 'wp_';

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
