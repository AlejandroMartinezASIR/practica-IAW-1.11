#!/bin/bash

# Configuramos para mostrar los comandos y finalizar si hay error
set -ex

#Importamos las variables de entorno
source .env

# Actualizamos los repositorios
apt update

# Actualiza los paquetes
apt upgrade -y

# Instalamos el cliente NFS 
apt install nfs-common -y

#  Creamos el punto de montaje en el cliente NFS
sudo mount $NFS_SERVER_IP:/var/www/html /var/www/html

echo "$NFS_SERVER_IP:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab