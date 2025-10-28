#!/bin/bash
# Script para verificar puertos, contenedores y conectividad

echo "🔍 Verificando configuración de red..."

# Detectar si es backend o frontend
if ss -tulpn 2>/dev/null | grep -q ':5000'; then
    VM_TYPE="backend"
    PORT=5000
elif ss -tulpn 2>/dev/null | grep -q ':80'; then
    VM_TYPE="frontend"
    PORT=80
else
    echo "⚠️  No se detectó ni puerto 5000 ni puerto 80"
    VM_TYPE="unknown"
fi

echo "📌 Tipo de VM detectado: $VM_TYPE"

# IP pública
PUBLIC_IP=$(curl -s ifconfig.me || echo "No disponible")
echo "🌐 IP Pública: $PUBLIC_IP"

# Puertos en escucha
echo "👂 Puertos en escucha:"
ss -tulpn 2>/dev/null | grep -E ':(22|80|5000)' || echo "No se encontraron puertos conocidos"

# Reglas de firewall
echo "🔥 Reglas de firewall (iptables):"
sudo iptables -L INPUT -n --line-numbers | grep -E "dpt:(22|80|5000)|ACCEPT.*tcp" || echo "No se encontraron reglas"

# Contenedores Docker
echo "🐳 Contenedores Docker:"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "No se pudieron listar contenedores"

# Pruebas de conectividad
if [ "$VM_TYPE" == "backend" ]; then
    echo "🧪 Probando backend en localhost:5000..."
    curl -s -o /dev/null -w "     Status: %{http_code}\n" http://localhost:5000/api/health || echo "❌ Error al conectar"

    echo "🧪 Probando backend en $PUBLIC_IP:5000..."
    curl -s -o /dev/null -w "     Status: %{http_code}\n" http://$PUBLIC_IP:5000/api/health || echo "❌ Error al conectar"
elif [ "$VM_TYPE" == "frontend" ]; then
    echo "🧪 Probando frontend en localhost:80..."
    curl -s -o /dev/null -w "     Status: %{http_code}\n" http://localhost:80 || echo "❌ Error al conectar"

    echo "🧪 Probando frontend en $PUBLIC_IP:80..."
    curl -s -o /dev/null -w "     Status: %{http_code}\n" http://$PUBLIC_IP || echo "❌ Error al conectar"
fi

echo ""
echo "✅ Verificación completada"

# Advertencias si puerto no está en escucha
if [ "$VM_TYPE" == "backend" ] && ! ss -tulpn | grep -q ':5000'; then
    echo "⚠️  Puerto 5000 no está en escucha"
elif [ "$VM_TYPE" == "frontend" ] && ! ss -tulpn | grep -q ':80'; then
    echo "⚠️  Puerto 80 no está en escucha"
fi

echo "💡 Asegúrate de que las Security Lists de OCI permiten tráfico entrante al puerto correspondiente"
