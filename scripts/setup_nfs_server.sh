#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

#Importamos las variables de entorno
source .env

# Actualizamos los repositorios
apt update

# Actualiza los paquetes
apt upgrade -y

#Instalamos el NFS Server
sudo apt install nfs-kernel-server -y

#Creamos el direcorio que vamos a compartir
mkdir -p /var/www/html

#Cambiamos el propietario y el grupo del directorio /var/www/html
sudo chown nobody:nogroup /var/www/html

# Copiamos el archivo de configuracion de NFS
cp ../nfs/exports /etc/exports

# Reemplazamos el valor de la plantilla de /etc/exports
sed -i "s#FRONTEND_NETWORK#$FRONTEND_NETWORK#" /etc/exports

#Reiniciamos el servicio de NFS
systemctl restart nfs-kernel-server 