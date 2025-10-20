#!/bin/bash
set -e

# Parámetros:
# $1 = usuario
# $2 = tipo de VM (frontend o backend)

USER=${1:-$USER}
VM_TYPE=${2:-""}

echo "--- Actualizando sistema ---"
sudo apt update && sudo apt upgrade -y

echo "--- Instalando dependencias: docker, docker-compose, ufw, git ---"
sudo apt install -y docker.io docker-compose ufw git

echo "--- Habilitando y arrancando docker ---"
sudo systemctl enable docker
sudo systemctl start docker

echo "--- Añadiendo usuario al grupo docker ---"
sudo usermod -aG docker $USER

echo "--- Configurando firewall (UFW) ---"
sudo apt install -y ufw

# Habilitar SSH primero (importante para no perder conexión)
sudo ufw allow 22/tcp

# Configurar puertos según el tipo de VM
if [ "$VM_TYPE" = "backend" ]; then
    echo "--- Configurando puertos para BACKEND ---"
    sudo ufw allow 3000/tcp
    sudo ufw allow 5000/tcp  # Por si acaso
elif [ "$VM_TYPE" = "frontend" ]; then
    echo "--- Configurando puertos para FRONTEND ---"
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
else
    echo "--- Configurando puertos generales ---"
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 3000/tcp
fi

# Activar firewall
sudo ufw --force enable
sudo ufw reload

echo "--- Estado del firewall ---"
sudo ufw status

echo "--- Creando carpeta de despliegue ---"
mkdir -p ~/deploy

echo "Setup completado ✅"
echo "Puertos abiertos:"
sudo ufw status numbered