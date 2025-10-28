#!/bin/bash
# Script para verificar el estado de los contenedores y servicios

echo ""
echo "========================================="
echo "   VERIFICACIÓN DE DESPLIEGUE"
echo "========================================="
echo ""

# Obtener IP pública
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "No disponible")
echo "🌐 IP Pública: $PUBLIC_IP"
echo ""

# Verificar contenedores Docker
echo "📦 Estado de los contenedores:"
sudo docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "webbiblioteca|NAMES"
echo ""

# Verificar logs del backend
echo "📝 Últimos logs del backend:"
sudo docker logs --tail 20 webbiblioteca-backend 2>/dev/null || echo "❌ No se pudo obtener logs del backend"
echo ""

# Verificar logs del frontend
echo "📝 Últimos logs del frontend:"
sudo docker logs --tail 10 webbiblioteca-frontend 2>/dev/null || echo "❌ No se pudo obtener logs del frontend"
echo ""

# Verificar puertos en escucha
echo "👂 Puertos en escucha:"
sudo ss -tulpn | grep -E ':(22|80|5000)' || echo "No se encontraron puertos"
echo ""

# Verificar reglas de firewall
echo "🔥 Reglas de firewall activas:"
sudo iptables -L INPUT -n --line-numbers | grep -E "dpt:(22|80|5000)|ACCEPT.*tcp" | head -10
echo ""

# Pruebas de conectividad
echo "🧪 Pruebas de conectividad:"

# Prueba backend local
echo -n "   - Backend (local): "
if curl -f -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/health 2>/dev/null | grep -q "200"; then
    echo "✅ OK (200)"
else
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/health 2>/dev/null)
    echo "❌ FAIL (Status: $HTTP_CODE)"
fi

# Prueba backend externo
echo -n "   - Backend (0.0.0.0): "
if curl -f -s -o /dev/null -w "%{http_code}" http://0.0.0.0:5000/api/health 2>/dev/null | grep -q "200"; then
    echo "✅ OK (200)"
else
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://0.0.0.0:5000/api/health 2>/dev/null)
    echo "❌ FAIL (Status: $HTTP_CODE)"
fi

# Prueba frontend local
echo -n "   - Frontend (local): "
if curl -f -s -o /dev/null -w "%{http_code}" http://localhost:80 2>/dev/null | grep -q -E "200|304"; then
    echo "✅ OK"
else
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80 2>/dev/null)
    echo "❌ FAIL (Status: $HTTP_CODE)"
fi

echo ""
echo "========================================="
echo "   URLs DE ACCESO"
echo "========================================="
echo "Frontend: http://$PUBLIC_IP"
echo "Backend:  http://$PUBLIC_IP:5000/api"
echo "========================================="
echo ""

# Recordatorio sobre Security Lists
echo "⚠️  RECORDATORIO:"
echo "   Asegúrate de que las Security Lists en Oracle Cloud tengan:"
echo "   - Ingress Rule: 0.0.0.0/0 → TCP → Puerto 80 (Frontend)"
echo "   - Ingress Rule: 0.0.0.0/0 → TCP → Puerto 5000 (Backend)"
echo ""

# Verificar si hay errores críticos
BACKEND_RUNNING=$(sudo docker ps | grep -c webbiblioteca-backend || echo 0)
FRONTEND_RUNNING=$(sudo docker ps | grep -c webbiblioteca-frontend || echo 0)

if [ "$BACKEND_RUNNING" -eq 0 ] || [ "$FRONTEND_RUNNING" -eq 0 ]; then
    echo "❌ ADVERTENCIA: Algunos contenedores no están corriendo"
    exit 1
else
    echo "✅ Todos los contenedores están activos"
fi