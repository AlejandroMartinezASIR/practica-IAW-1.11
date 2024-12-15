#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

# Importamos el archivo de variables 
source .env

# Actualizamos los repositorios
apt update

# Actualiza los paquetes
apt upgrade -y

#Instalamos nginx
apt install nginx -y

# Deshabilitamos el virtualhost por defecto
if [ -f "/etc/nginx/sites-enabled/default"]; then
unlink /etc/nginx/sites-enabled/default
fi
# Copiamos el archivo de configuración de Nginx
cp ../conf/load-balancer.conf /etc/nginx/sites-available

# Sustituimos los valores de la plantilla del archivo de configuración
sed -i "s/IP_FRONTEND_1/$IP_FRONTEND_1/" /etc/nginx/sites-available/load-balancer.conf
sed -i "s/IP_FRONTEND_2/$IP_FRONTEND_2/" /etc/nginx/sites-available/load-balancer.conf

# Habilitamos el virtualhost del balanceador de carga
if [ ! -f "/etc/nginx/sites-enabled/load-balancer.conf" ]; then 
ln -s /etc/nginx/sites-available/load-balancer.conf /etc/nginx/sites-enabled
fi

# Reinciamos el balanceador de carga
systemctl restart nginx