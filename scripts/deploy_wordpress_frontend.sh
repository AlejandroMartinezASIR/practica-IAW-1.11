#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

#Importamos las variables de entorno
source .env

# Descargamos el wP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Le asignamos permisos de ejecución al archivo wp-cli.phar.
chmod +x wp-cli.phar

# Movemos el archivo wp-cli.phar al directorio /usr/local/bin/
mv wp-cli.phar /usr/local/bin/wp

# Eliminamos instalaciones previas en /var/www/html
rm -rf $WORDPRESS_DIRECTORY/*

# Descargamos el código fuente de WordPress
wp core download --locale=es_ES --path=/var/www/html --allow-root

# Cambiamos el propietario y el grupo al directorio /var/www/html
chown -R www-data:www-data /var/www/html/

# Creamos el archivo de configuración
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$WORDPRESS_DB_HOST \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

# Instalación de WordPress

wp core install \
  --url=$LE_DOMAIN\
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASS \
  --admin_email=$WORDPRESS_ADMIN_EMAIL \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root  

  # Instalamos y actiamos el theme midnscape
  wp theme install mindscape --activate --path=$WORDPRESS_DIRECTORY --allow-root

  #Instalamos un plugin
  wp plugin install wps-hide-login --activate --path=$WORDPRESS_DIRECTORY --allow-root

  #Configuramosel plugin de Url
  wp option update whl_page "$WORDPRESS_HIDE_LOGIN" --path=$WORDPRESS_DIRECTORY --allow-root
  
  # Enlaces permanentes
  wp rewrite structure '/%postname%/' --path=$WORDPRESS_DIRECTORY --allow-root

  # Copiamos el archivo .htaccess
  cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY
  
  # Modificamos el propietario y el grupo del directio de /var/www/html
  chown -R www-data:www-data $WORDPRESS_DIRECTORY


