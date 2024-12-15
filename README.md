# Practica 01-11

```
├── README.md
├── conf
│   ├── load-balancer.conf
│   └── 000-default.conf
├── htaccess
│   └── .htaccess
├── php
│   └── index.php
└── scripts
    ├── .env
    ├── install_load_balancer.sh
    ├── install_lamp_frontend.sh
    ├── install_lamp_backend.sh
    ├── setup_letsencrypt_https.sh
    ├── install_wordpress.sh
    ├── install_nfs_client.sh
    └── install_nfs_server.sh
```
**Balanceador de carga**
-   Instalar el software necesario.
-   Habilitar los módulos necesarios y configurar  [Apache HTTP Server](https://www.apache.org/)  como  [proxy inverso](https://httpd.apache.org/docs/trunk/es/howto/reverse_proxy.html).
-   Instalar y configurar  [Certbot](https://certbot.eff.org/)  para solicitar un certificado HTTPS.

**NFS Server (Capa de Frontend)**
-   Instalar el software necesario.
-   Crear el directorio que utilizará para compartir el contenido con los servidores web.
-   Configurar el archivo  `/etc/exports`  para permitir el acceso al directorio compartido solo a los servidores web.

**Servidores web (Capa de Frontend)**
-   Instalar el software necesario.
-   Configurar el archivo de Apache para incluir la directiva  `AllowOverride All`.
-   Habilitar el módulo  `rewrite`.
-   Sincronizar el contenido estático en la capa de  _Front-End_.
    -   Crear un punto de montaje con el directorio compartido del servidor NFS.
    -   Configurar el archivo  `/etc/fstab`  para montar automáticamente el directorio al iniciar el sistema.
-   Descargar la última versión de  [WordPress](https://wordpress.org/)  y descomprimir en el directorio apropiado.
-   [Configurar WordPress para que pueda conectar con MySQL](https://codex.wordpress.org/Editing_wp-config.php#Configure_Database_Settings).
-   Configuración de las  _Security Keys_.

**Servidor de base de datos (Capa de Backend)**
-   Instalar el software necesario.
-   Configurar  [MySQL](https://www.mysql.com/)  para que acepte conexiones que no sean de  _localhost_.
-   Crear una base de datos para  [WordPress](https://wordpress.org/).
-   Crear un usuario para la base de datos de  [WordPress](https://wordpress.org/)  y asignarle los permisos apropiados.
- 
## install_lamp_frontend
Configuramos para mostrar los comandos y finalizar si hay error

    set -ex

Actualizamos los repositorios

    apt update

Actualiza los paquetes

    apt upgrade -y

Instalamos el servidor web Apache

    apt install apache2 -y

Habilitamos el modulo rewrite

    a2enmod rewrite

Copiamos el archivo de configuración de Apache

    cp ../conf/000-default.conf /etc/apache2/sites-available

Instalamos PHP y algunos módulos de php para Apache y MySQL

    apt install php libapache2-mod-php php-mysql -y

Reiniciamos el servicio de Apache

    systemctl restart apache2

Copiamos el script de prueba de PHP en /var/www/html

    cp ../php/index.php /var/www/html

Modificamos el propietario y el grupo del archivo index.php

    chown -R www-data:www-data /var/www/html

## install_lamp_backend

Configuramos para mostrar los comandos y finalizar si hay error

    set -ex

Importamos el archivo de variables 

    source .env

Actualizamos los repositorios

    apt update

Actualiza los paquetes

    apt upgrade -y

Instalamos mysql server

    apt install mysql-server -y

Configuramos el archivo /etc/mysql/mysql.conf.d/mysqld.cnf

    sed -i "s/127.0.0.1/$BACKEND_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf

Reiniciamos el servicio de MySQL

    systemctl restart mysql

## install_load_balancer
Configuramos para mostrar los comandos y finalizar si hay error

    set -ex

Importamos el archivo de variables 
    
    source .env

Actualizamos los repositorios

    apt update

Actualiza los paquetes

    apt upgrade -y

Instalamos nginx

    apt install nginx -y

Deshabilitamos el virtualhost por defecto

    if [ -f "/etc/nginx/sites-enabled/default"]; then
    unlink /etc/nginx/sites-enabled/default
    fi 

Copiamos el archivo de configuración de Nginx
    
    cp ../conf/load-balancer.conf /etc/nginx/sites-available

Sustituimos los valores de la plantilla del archivo de configuración
    
    sed -i "s/IP_FRONTEND_1/$IP_FRONTEND_1/" /etc/nginx/sites-available/load-balancer.conf
    sed -i "s/IP_FRONTEND_2/$IP_FRONTEND_2/" /etc/nginx/sites-available/load-balancer.conf

Habilitamos el virtualhost del balanceador de carga

    if [ ! -f "/etc/nginx/sites-enabled/load-balancer.conf" ]; then 
    ln -s /etc/nginx/sites-available/load-balancer.conf /etc/nginx/sites-enabled
    fi

Reinciamos el balanceador de carga

    systemctl restart nginx

## install_wordpress

Configuramos para mostrar los comandos y finalizar si hay error

    set -ex

Importamos las variables de entorno

    source .env

Descargamos el wP-CLI

    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

Le asignamos permisos de ejecución al archivo wp-cli.phar.

    chmod +x wp-cli.phar

Movemos el archivo wp-cli.phar al directorio /usr/local/bin/

    mv wp-cli.phar /usr/local/bin/wp

Eliminamos instalaciones previas en /var/www/html

    rm -rf $WORDPRESS_DIRECTORY/*

Descargamos el código fuente de WordPress

    wp core download --locale=es_ES --path=/var/www/html --allow-root

Cambiamos el propietario y el grupo al directorio /var/www/html

    chown -R www-data:www-data /var/www/html/

Creamos el archivo de configuración

    wp config create \
    --dbname=$WORDPRESS_DB_NAME \
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$WORDPRESS_DB_PASSWORD \
    --dbhost=$WORDPRESS_DB_HOST \
    --path=$WORDPRESS_DIRECTORY \
    --allow-root

Instalación de WordPress

    wp core install \
    --url=$LE_DOMAIN\
    --title="$WORDPRESS_TITLE" \
    --admin_user=$WORDPRESS_ADMIN_USER \
    --admin_password=$WORDPRESS_ADMIN_PASS \
    --admin_email=$WORDPRESS_ADMIN_EMAIL \
    --path=$WORDPRESS_DIRECTORY \
    --allow-root  

Instalamos y actiamos el theme midnscape

  wp theme install mindscape --activate --path=$WORDPRESS_DIRECTORY --allow-root

Instalamos un plugin

  wp plugin install wps-hide-login --activate --path=$WORDPRESS_DIRECTORY --allow-root

Configuramosel plugin de Url

  wp option update whl_page "$WORDPRESS_HIDE_LOGIN" --path=$WORDPRESS_DIRECTORY --allow-root
  
Enlaces permanentes

  wp rewrite structure '/%postname%/' --path=$WORDPRESS_DIRECTORY --allow-root

Copiamos el archivo .htaccess

  cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY
  
Modificamos el propietario y el grupo del directio de /var/www/html

  chown -R www-data:www-data $WORDPRESS_DIRECTORY
    
  
## setup_letsencrypt_https.sh
1.  `set -ex`: Configura el modo de ejecución del script. `-e` hace que el script se detenga si algún comando devuelve un código de error, y `-x` muestra los comandos ejecutados con sus argumentos y resultados.
    
2.  `source .env`: Carga las variables de entorno desde el archivo `.env` al script.
    
3.  `apt update`: Actualiza la lista de paquetes disponibles para su instalación.
    
4.  `snap install core`: Instala el paquete core de **Snap**.
    
5.  `snap refresh core`: Actualiza el paquete core de **Snap** a la última versión disponible.
    
6.  `apt remove certbot`: Desinstala el paquete **certbot**.
    
7.  `snap install --classic certbot`: Instala **certbot** como un paquete **Snap** en modo clásico.
    
8.  `ln -fs /snap/bin/certbot /usr/bin/certbot`: Crea un enlace simbólico para que el ejecutable **certbot** en */snap/bin/* esté disponible en */usr/bin/.*
    
9.  `certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive`: Utiliza **certbot** para obtener y configurar certificados **SSL/TLS** para el dominio especificado utilizando el método de autenticación de **Apache**. Las opciones proporcionan el correo electrónico del propietario del certificado y aceptan los términos del servicio sin efectuar emails.

## .env
#Configuramos las variables

    LE_EMAIL=demo@demo.es
    LE_DOMAIN=practica-wordpress2.ddnsking.com

#Variables para WordPress
    
    WORDPRESS_DB_NAME=wp_db
    WORDPRESS_DB_USER=wp_user
    WORDPRESS_DB_PASSWORD=wp_pass
    IP_CLIENTE_MYSQL=172.31.%
    WORDPRESS_DB_HOST=172.31.28.128
    WORDPRESS_DIRECTORY="/var/www/html"
    WORDPRESS_TITLE="IAW"
    WORDPRESS_ADMIN_USER=admin
    WORDPRESS_ADMIN_PASS=admin
    WORDPRESS_ADMIN_EMAIL=demo@demo.es
    WORDPRESS_HIDE_LOGIN_URL=nadaimportante
    FRONTEND_PRIVATE_IP=172.31.31.48
    BACKEND_PRIVATE_IP=172.31.28.128
    IP_FRONTEND_1=172.31.31.48
    IP_FRONTEND_2=172.31.16.250
    FRONTEND_NETWORK=172.31.0.0/16
    NFS_SERVER_IP=172.31.21.10

