#!/bin/bash
# Cloud-init para configurar Docker en Ubuntu 22.04

set -e

echo "🚀 Iniciando configuración de la VM..."

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Instalar dependencias
echo "📦 Instalando dependencias..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    net-tools \
    iptables-persistent

# Configurar repositorio de Docker
echo "🐳 Configurando repositorio de Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
echo "🐳 Instalando Docker..."
sudo apt-get update -y
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Añadir usuario ubuntu al grupo docker
if id -u ubuntu >/dev/null 2>&1; then
    sudo usermod -aG docker ubuntu
fi

# Habilitar y arrancar Docker
sudo systemctl enable docker
sudo systemctl start docker

# Configurar firewall con iptables
echo "🔥 Configurando firewall..."

# Limpiar reglas existentes pero mantener las básicas
sudo iptables -F INPUT || true

# Permitir tráfico establecido y relacionado
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Permitir SSH (CRÍTICO)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir HTTP (Frontend en puerto 80)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Permitir Backend (puerto 5000)
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# Remover regla de REJECT de Oracle Cloud si existe
sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true

# Guardar reglas permanentemente
sudo netfilter-persistent save

# Crear directorio para la aplicación
sudo mkdir -p /home/ubuntu/deploy
sudo chown ubuntu:ubuntu /home/ubuntu/deploy

# Esperar a que Docker esté completamente listo
echo "⏳ Esperando a que Docker esté listo..."
sleep 5

# Verificar instalación
echo "✅ Verificando instalación..."
docker --version
docker compose version

echo "✅ Configuración de VM completada exitosamente!"
echo "🔥 Puertos abiertos: 22 (SSH), 80 (HTTP), 5000 (Backend API)"

# Mostrar información útil
echo ""
echo "ℹ️  Información de la VM:"
echo "   - Usuario: ubuntu"
echo "   - Docker instalado: $(docker --version)"
echo "   - Puertos configurados: 22, 80, 5000"
echo ""