#!/bin/sh
set -e

mkdir -p /var/lib/mysql /var/run/mysqld /var/log/mysql
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql
chmod 777 /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-networking

	echo "Starting MariaDB for initial setup..."
	/usr/bin/mysqld --user=mysql --bootstrap << EOF_SQL
USE mysql;
FLUSH PRIVILEGES
CREATE DATABASE IF NOT EXISTS \${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '\${MYSQL_USER}'@'%' IDENTIFIED BY '\${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \${MYSQL_DATABASE}.* TO '\${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '\${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF_SQL

	echo "Database initialized successfully!"
fi

echo "Starting MariaDB server..."
exec /usr/bin/mysqld --user=mysql --console
