#!/bin/bash

# Script de setup para VMs (backend o frontend)
# Uso: ./setup_vm.sh <username> <vm_type>
# Ejemplo: ./setup_vm.sh ubuntu backend

set -e

USERNAME=$1
VM_TYPE=$2

if [ -z "$USERNAME" ] || [ -z "$VM_TYPE" ]; then
    echo "❌ Error: Faltan argumentos"
    echo "Uso: ./setup_vm.sh <username> <vm_type>"
    echo "Ejemplo: ./setup_vm.sh ubuntu backend"
    exit 1
fi

echo "🚀 Iniciando setup de VM tipo: $VM_TYPE"
echo "👤 Usuario: $USERNAME"

# Actualizar sistema
echo "📦 Actualizando sistema..."
sudo apt-get update -qq

# Instalar Docker si no está instalado
if ! command -v docker &> /dev/null; then
    echo "🐳 Instalando Docker..."
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USERNAME
    echo "✅ Docker instalado"
else
    echo "✅ Docker ya está instalado"
fi

# Instalar Docker Compose si no está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose instalado"
else
    echo "✅ Docker Compose ya está instalado"
fi

# Asegurar que Docker esté corriendo
sudo systemctl enable docker
sudo systemctl start docker

# Configurar firewall según el tipo de VM
echo "🔥 Configurando firewall..."

# Instalar iptables-persistent
if ! dpkg -l | grep -q iptables-persistent; then
    echo "📦 Instalando iptables-persistent..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
fi

# Permitir conexiones establecidas
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT || true
sudo iptables -A INPUT -i lo -j ACCEPT || true
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT || true

# Eliminar regla de REJECT de Oracle Cloud si existe
sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true

if [ "$VM_TYPE" == "backend" ]; then
    echo "🔓 Abriendo puerto 5000 para backend..."
    sudo iptables -I INPUT 1 -p tcp --dport 5000 -j ACCEPT
    echo "✅ Puerto 5000 abierto"
    
elif [ "$VM_TYPE" == "frontend" ]; then
    echo "🔓 Abriendo puerto 80 para frontend..."
    sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
    echo "✅ Puerto 80 abierto"
fi

# Guardar reglas de firewall
echo "💾 Guardando reglas de firewall..."
sudo netfilter-persistent save

# Limpiar contenedores antiguos
echo "🧹 Limpiando contenedores antiguos..."
sudo docker system prune -af --volumes || true

echo ""
echo "✅ Setup completado para $VM_TYPE"
echo "📋 Puertos abiertos:"
sudo iptables -L INPUT -n --line-numbers | grep -E "dpt:(22|80|5000)" || echo "No se encontraron reglas de puertos"
echo ""
echo "⚠️  RECORDATORIO: Configura también las Security Lists en Oracle Cloud Console"
echo ""