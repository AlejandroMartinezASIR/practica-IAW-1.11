#!/bin/bash
set -ex

#Actuallizamos los paquetes
apt-get update

apt-get upgrade -y

#Vinculamos las variables
source .env

#Instalamos nfs server
apt install nfs-kernel-server -y

#Creamos el directorio que vamos a compartir
mkdir -p /var/www/html

#Cambiamos los permisos del directorio
chown nobody:nogroup /var/www/html

#Copiamos el archivo de configuracion NFS
cp ../nfs/exports /etc/exports

#remplazamos el valor de la plantilla de /etc/exports
sed -i "s#FRONTEND_NETWORK#$FRONTEND_NETWORK#" /etc/exports

#Reiniciamos el servicio
systemctl restart nfs-kernel-server
