#!/bin/bash

# Script para abrir puertos en Oracle Cloud Ubuntu
# Uso: ./open_ports.sh [backend|frontend]

set -e

VM_TYPE=$1

if [ -z "$VM_TYPE" ]; then
    echo "❌ Error: Debes especificar el tipo de VM (backend o frontend)"
    echo "Uso: ./open_ports.sh [backend|frontend]"
    exit 1
fi

echo "🔧 Configurando firewall para $VM_TYPE..."

# Instalar iptables-persistent si no está instalado
if ! dpkg -l | grep -q iptables-persistent; then
    echo "📦 Instalando iptables-persistent..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
fi

# Limpiar reglas existentes de INPUT (pero mantener las básicas)
echo "🧹 Limpiando reglas existentes..."

# Permitir tráfico establecido y relacionado
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Permitir loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Permitir SSH (CRÍTICO - no bloquear SSH)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

if [ "$VM_TYPE" == "backend" ]; then
    echo "🔓 Abriendo puerto 5000 para backend..."
    
    # Abrir puerto 5000 en iptables
    sudo iptables -I INPUT 1 -p tcp --dport 5000 -j ACCEPT
    
    # Verificar que no esté bloqueado por Oracle Cloud iptables
    sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
    
    echo "✅ Puerto 5000 abierto"
    
elif [ "$VM_TYPE" == "frontend" ]; then
    echo "🔓 Abriendo puerto 80 para frontend..."
    
    # Abrir puerto 80 en iptables
    sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
    
    # Verificar que no esté bloqueado por Oracle Cloud iptables
    sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true
    
    echo "✅ Puerto 80 abierto"
else
    echo "❌ Error: VM_TYPE debe ser 'backend' o 'frontend'"
    exit 1
fi

# Guardar reglas permanentemente
echo "💾 Guardando reglas de firewall..."
sudo netfilter-persistent save

# Mostrar reglas actuales
echo ""
echo "📋 Reglas de firewall actuales:"
sudo iptables -L INPUT -n --line-numbers | grep -E "dpt:(22|80|5000)|Chain INPUT"

echo ""
echo "✅ Configuración de firewall completada para $VM_TYPE"
echo ""
echo "⚠️  IMPORTANTE: También debes configurar las Security Lists en Oracle Cloud Console:"
echo "   1. Ve a: Networking > Virtual Cloud Networks > tu VCN > Security Lists"
echo "   2. Agrega Ingress Rules:"
if [ "$VM_TYPE" == "backend" ]; then
    echo "      - Source CIDR: 0.0.0.0/0"
    echo "      - IP Protocol: TCP"
    echo "      - Destination Port: 5000"
elif [ "$VM_TYPE" == "frontend" ]; then
    echo "      - Source CIDR: 0.0.0.0/0"
    echo "      - IP Protocol: TCP"
    echo "      - Destination Port: 80"
fi
echo ""