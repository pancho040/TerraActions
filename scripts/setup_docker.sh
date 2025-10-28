#!/bin/bash
# Script de emergencia para instalar Docker si no está disponible
# Este script solo se ejecuta si Docker no fue instalado por cloud-init

set -e

echo "🐳 Instalando Docker (método de respaldo)..."

# Actualizar sistema
sudo apt-get update -y

# Instalar dependencias
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Configurar repositorio de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt-get update -y
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Añadir usuario al grupo docker
sudo usermod -aG docker $USER

# Habilitar y arrancar Docker
sudo systemctl enable docker
sudo systemctl start docker

# Configurar firewall
if ! dpkg -l | grep -q iptables-persistent; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
fi

# Permitir puertos necesarios
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT
sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true

# Guardar reglas
sudo netfilter-persistent save

echo "✅ Docker instalado correctamente"
docker --version
docker compose version