#!/bin/bash
# Script para abrir puertos en Ubuntu/OCI
# Uso: ./open_ports.sh [backend|frontend]

set -e

VM_TYPE=$1
if [ -z "$VM_TYPE" ]; then
    echo "❌ Debes especificar el tipo de VM: backend o frontend"
    exit 1
fi

echo "🔧 Configurando firewall para $VM_TYPE..."

# Instalar iptables-persistent si no está
if ! dpkg -l | grep -q iptables-persistent; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
fi

# Permitir tráfico establecido y loopback
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Abrir puerto correspondiente
if [ "$VM_TYPE" == "backend" ]; then
    PORT=5000
elif [ "$VM_TYPE" == "frontend" ]; then
    PORT=80
else
    echo "❌ Tipo de VM incorrecto"
    exit 1
fi

sudo iptables -I INPUT 1 -p tcp --dport $PORT -j ACCEPT
sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true

# Guardar reglas permanentemente
sudo netfilter-persistent save

echo "✅ Puerto $PORT abierto correctamente"

# Recomendación de Security List
echo "⚠️  Recuerda abrir el puerto $PORT en las Security Lists de OCI (0.0.0.0/0 → TCP → $PORT)"
