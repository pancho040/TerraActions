#!/bin/bash
# Script de cloud-init para instalar Docker y Docker Compose en Ubuntu 22.04

set -e

# 0. Opcional: actualizar paquetes y realizar upgrade ligero
sudo apt-get update -y
sudo apt-get upgrade -y

# 1. Instalar prerequisitos y claves
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 2. Añadir repo Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
 
# 3. Instalar Docker y plugins (incluye plugin compose)
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Añadir usuario 'ubuntu' (si existe) al grupo docker
if id -u ubuntu >/dev/null 2>&1; then
    sudo usermod -aG docker ubuntu || true
fi

# 5. Habilitar y arrancar Docker
sudo systemctl enable docker
sudo systemctl start docker

# 6. Permitir firewall básico (opcional - ejemplo: abrir puerto 80 y 443)
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow OpenSSH
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw --force enable
fi

echo "Docker y Docker Compose instalados y listos."
