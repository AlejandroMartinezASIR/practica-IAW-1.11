#!/bin/bash

set -ex

source .env

apt update

apt upgrade -y

apt install apache2 -y

cp /home/ubuntu/practica-01-11/conf/load-balancer.conf /etc/apache2/sites-available

sed -i "s/IP_HTTP_SERVER1/$IP_HTTP_SERVER1/" /etc/apache2/sites-available/load-balancer.conf
sed -i "s/IP_HTTP_SERVER2/$IP_HTTP_SERVER2"/ /etc/apache2/sites-available/load-balancer.conf

a2enmod proxy

a2enmod proxy_http

a2enmod proxy_balancer

a2dissite 000-default.conf

a2ensite load-balancer.conf 

systemctl restart apache2