#!/bin/bash
USER_TO_ADD="$1"

if [ -z "$USER_TO_ADD" ]; then
  echo "Usage: setup_vm.sh <username>"
  exit 1
fi

set -e

echo "--- Actualizando sistema ---"
sudo apt update -y && sudo apt upgrade -y

echo "--- Instalando dependencias: docker, docker-compose, ufw, git ---"
sudo apt install -y docker.io docker-compose git

echo "--- Habilitando y arrancando docker ---"
sudo systemctl enable docker
sudo systemctl start docker

echo "--- Añadiendo usuario al grupo docker ---"
sudo usermod -aG docker "$USER_TO_ADD"

echo "--- Configurando firewall (UFW) ---"
sudo apt install -y ufw
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 3000/tcp
sudo ufw --force enable

echo "--- Creando carpeta de despliegue ---"
DEPLOY_PATH="/home/$USER_TO_ADD/deploy"
sudo mkdir -p "$DEPLOY_PATH"
sudo chown "$USER_TO_ADD":"$USER_TO_ADD" "$DEPLOY_PATH"

echo "Setup completado ✅"
