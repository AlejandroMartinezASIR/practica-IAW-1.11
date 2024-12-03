#!/bin/bash

#Para mostrar los comandos que son ejecutables con -x, si se pone -ex nos muestra que comando falla
set -ex 

# Ponemos las variables del archivo .env
source .env

#Poner sudo cuando se vaya a lanzar el script
apt update

#Actualizar los paquetes del sistema
apt upgrade -y

#En primer lugar, tendremos que instalar el servidor web Nginx
apt install nginx -y