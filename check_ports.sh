#!/bin/bash

# Script para verificar puertos y conectividad
# Detecta automáticamente si es backend o frontend

echo "🔍 Verificando configuración de red..."
echo ""

# Detectar puertos activos
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
echo ""

# Mostrar IP pública
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "No disponible")
echo "🌐 IP Pública: $PUBLIC_IP"
echo ""

# Verificar puertos en escucha
echo "👂 Puertos en escucha:"
ss -tulpn 2>/dev/null | grep -E ':(22|80|3000|5000)' || echo "No se encontraron puertos conocidos"
echo ""

# Verificar reglas de firewall
echo "🔥 Reglas de firewall (iptables):"
sudo iptables -L INPUT -n --line-numbers | grep -E "dpt:(22|80|3000|5000)|ACCEPT.*tcp" | head -10 || echo "No se encontraron reglas"
echo ""

# Verificar contenedores Docker
echo "🐳 Contenedores Docker:"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No se pudieron listar contenedores"
echo ""

# Pruebas de conectividad
if [ "$VM_TYPE" == "backend" ]; then
    echo "🧪 Prueba de conectividad al backend:"
    echo "   - Interno (localhost:5000):"
    curl -s -o /dev/null -w "     Status: %{http_code}\n" http://localhost:5000/api/health 2>/dev/null || echo "     ❌ Error al conectar"
    
    echo "   - Externo (0.0.0.0:5000):"
    curl -s -o /dev/null -w "     Status: %{http_code}\n" http://0.0.0.0:5000/api/health 2>/dev/null || echo "     ❌ Error al conectar"
    
elif [ "$VM_TYPE" == "frontend" ]; then
    echo "🧪 Prueba de conectividad al frontend:"
    echo "   - Interno (localhost:80):"
    curl -s -o /dev/null -w "     Status: %{http_code}\n" http://localhost:80 2>/dev/null || echo "     ❌ Error al conectar"
fi

echo ""
echo "✅ Verificación completada"
echo ""

# Recomendaciones
if [ "$VM_TYPE" == "backend" ] && ! ss -tulpn 2>/dev/null | grep -q ':5000'; then
    echo "⚠️  ADVERTENCIA: El puerto 5000 no está en escucha"
    echo "   Verifica que el contenedor backend esté corriendo correctamente"
    echo ""
elif [ "$VM_TYPE" == "frontend" ] && ! ss -tulpn 2>/dev/null | grep -q ':80'; then
    echo "⚠️  ADVERTENCIA: El puerto 80 no está en escucha"
    echo "   Verifica que el contenedor frontend esté corriendo correctamente"
    echo ""
fi

# Verificar Oracle Cloud Security Lists
echo "💡 RECORDATORIO:"
echo "   Asegúrate de que las Security Lists en Oracle Cloud tengan:"
if [ "$VM_TYPE" == "backend" ]; then
    echo "   - Ingress Rule: 0.0.0.0/0 → TCP → Puerto 5000"
elif [ "$VM_TYPE" == "frontend" ]; then
    echo "   - Ingress Rule: 0.0.0.0/0 → TCP → Puerto 80"
fi
echo ""