#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

# Actualizamos los repositorios
apt update

# Actualiza los paquetes
apt upgrade -y

# Instalamos el servidor web Apache
apt install apache2 -y

# Habilitamos el modulo rewrite
a2enmod rewrite

# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available

# Instalamos PHP y algunos módulos de php para Apache y MySQL
apt install php libapache2-mod-php php-mysql -y

# Reiniciamos el servicio de Apache
systemctl restart apache2

# Copiamos el script de prueba de PHP en /var/www/html
cp ../php/index.php /var/www/html

# Modificamos el propietario y el grupo del archivo index.php
chown -R www-data:www-data /var/www/html