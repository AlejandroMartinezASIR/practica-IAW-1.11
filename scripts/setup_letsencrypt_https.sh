#!/bin/bash

set -ex

source .env

apt update

apt upgrade -y

snap install core

snap refresh core

apt remove certbot

snap install --classic certbot

ln -sf /snap/bin/certbot /usr/bin/certbot 

certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive