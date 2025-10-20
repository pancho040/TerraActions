#!/bin/bash
set -e

echo "--- Actualizando sistema ---"
sudo apt update && sudo apt upgrade -y

echo "--- Instalando dependencias: docker, docker-compose, ufw, git ---"
sudo apt install -y docker.io docker-compose ufw git

echo "--- Habilitando y arrancando docker ---"
sudo systemctl enable docker
sudo systemctl start docker

echo "--- Añadiendo usuario al grupo docker ---"
sudo usermod -aG docker ${1:-$USER}

echo "--- Configurando firewall (UFW) ---"
sudo apt install -y ufw
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp  # ⭐ AGREGAR ESTO
sudo ufw --force enable

echo "--- Creando carpeta de despliegue ---"
mkdir -p ~/deploy

echo "Setup completado ✅"