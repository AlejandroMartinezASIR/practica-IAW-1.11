#!/bin/bash
set -ex

apt-get update

apt-get upgrade -y

source .env

apt-get install mysql-server -y

sed -i "s/127.0.0.1/$MYSQL_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo mysql -u root <<< "DROP USER IF EXISTS '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL';"
sudo mysql -u root <<< "CREATE USER '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';"
sudo mysql -u root <<< "GRANT ALL PRIVILEGES ON \`$WORDPRESS_DB_NAME\`.* TO '$WORDPRESS_DB_USER'@'$IP_CLIENTE_MYSQL';"
sudo mysql -u root <<< "FLUSH PRIVILEGES;"

systemctl restart mysql