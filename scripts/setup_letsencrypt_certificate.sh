#!/bin/bash

#Mostrar los comandos que se van ejecutando
set -ex

#Importamos las variables de entorno
source .env

# Instalamos y Actualizamos snap
sudo snap install core
sudo snap refresh core

# Eliminamos instalaciones previas de cerbot con apt
apt remove certbot -y

# Instalamos el cliente de cerbot
snap install --classic certbot

# Creamos un alias para el comando cerbot
ln -fs /snap/bin/cerbot /usr/bin/cerbot

# Solicitamos un certificado a Let´s Encrypt
sudo certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive
