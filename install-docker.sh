#!/bin/bash

#------------------------------------------------------------------------
# Instalación de Docker
#------------------------------------------------------------------------

# Actualizamos los repositorios
apt update -y

# Actualizamos los paquetes (opcional)
# apt upgrade -y

# Instalamos los paquetes
apt install docker -y
apt install docker-compose -y

# Encendemos docker
systemctl enable docker
systemctl start docker

# Lanzamos docker-compose
docker-compose up -d