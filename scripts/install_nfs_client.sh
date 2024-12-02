#!/bin/bash
#salir del script en caso de error
set -ex

#actualizamos
apt-get update

apt-get upgrade -y

#Vinculamos las variables
source .env

#Instalamos el cliente NFS
apt install nfs-common -y

#montamos la carpeta del servidor NFS 
mount $SERVER_PRIVATE_IP:/var/www/html /var/www/html

# si creas un archivo en /var/www/html aqui tiene que aparecer en NFS_server

nano /etc/fstab

echo "$SERVER_PRIVATE_IP:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab