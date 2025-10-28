#!/bin/bash
# Cloud-init para configurar Docker en Ubuntu 22.04
# Este script se ejecuta automáticamente al crear la VM

set -e

# Redirigir output a archivo de log
exec > >(tee /var/log/cloud-init-custom.log)
exec 2>&1

echo "=========================================="
echo "🚀 Iniciando configuración de la VM..."
echo "Fecha: $(date)"
echo "=========================================="

# Actualizar sistema
echo "📦 Actualizando sistema..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# Instalar dependencias
echo "📦 Instalando dependencias..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    net-tools

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
echo "👤 Añadiendo usuario ubuntu al grupo docker..."
if id -u ubuntu >/dev/null 2>&1; then
    sudo usermod -aG docker ubuntu
fi

# Habilitar y arrancar Docker
echo "🔧 Habilitando y arrancando Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Esperar a que Docker esté completamente listo
echo "⏳ Esperando a que Docker esté listo..."
for i in {1..30}; do
    if sudo docker info >/dev/null 2>&1; then
        echo "✅ Docker está funcionando correctamente"
        break
    fi
    echo "Esperando Docker... intento $i/30"
    sleep 2
done

# Instalar iptables-persistent
echo "🔥 Instalando iptables-persistent..."
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install -y iptables-persistent

# Configurar firewall con iptables
echo "🔥 Configurando firewall..."

# Limpiar reglas existentes
sudo iptables -F INPUT 2>/dev/null || true

# Permitir tráfico establecido y relacionado
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Permitir SSH (CRÍTICO - puerto 22)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir HTTP (Frontend - puerto 80)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Permitir Backend API (puerto 5000)
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

# Permitir ICMP (ping)
sudo iptables -A INPUT -p icmp -j ACCEPT

# Remover regla de REJECT de Oracle Cloud si existe
sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true

# Guardar reglas permanentemente
echo "💾 Guardando reglas de firewall..."
sudo netfilter-persistent save

# Crear directorio para la aplicación
echo "📁 Creando directorios..."
sudo mkdir -p /home/ubuntu/deploy
sudo mkdir -p /home/ubuntu/deploy/scripts
sudo chown -R ubuntu:ubuntu /home/ubuntu/deploy

# Verificar instalación
echo "✅ Verificando instalación..."
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"

# Mostrar reglas de firewall
echo ""
echo "🔥 Reglas de firewall configuradas:"
sudo iptables -L INPUT -n --line-numbers | head -20

# Crear archivo de marcador para indicar que cloud-init terminó
echo "✅ Cloud-init completado exitosamente en $(date)" | sudo tee /var/lib/cloud/instance/cloud-init-complete.flag

echo ""
echo "=========================================="
echo "✅ Configuración de VM completada!"
echo "Fecha: $(date)"
echo "🔥 Puertos abiertos: 22 (SSH), 80 (HTTP), 5000 (Backend API)"
echo "=========================================="