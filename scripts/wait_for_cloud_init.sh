#!/bin/bash
# Script para esperar a que cloud-init termine completamente
# Se ejecuta vía SSH desde GitHub Actions

set -e

echo "=========================================="
echo "🔍 Verificando estado de cloud-init"
echo "=========================================="
echo ""

# Función para verificar si cloud-init está ejecutándose
check_cloud_init() {
    if sudo cloud-init status 2>/dev/null | grep -q "status: done"; then
        return 0
    else
        return 1
    fi
}

# Función para verificar si hay procesos apt/dpkg bloqueados
check_apt_locks() {
    if sudo fuser /var/lib/dpkg/lock-frontend 2>/dev/null; then
        return 1
    fi
    if sudo fuser /var/lib/apt/lists/lock 2>/dev/null; then
        return 1
    fi
    return 0
}

# Esperar a que cloud-init termine (máximo 15 minutos)
echo "⏳ Esperando a que cloud-init termine..."
TIMEOUT=900  # 15 minutos
ELAPSED=0
INTERVAL=10

while [ $ELAPSED -lt $TIMEOUT ]; do
    if check_cloud_init; then
        echo "✅ cloud-init ha terminado exitosamente"
        break
    fi
    
    # Mostrar estado actual
    STATUS=$(sudo cloud-init status 2>/dev/null || echo "unknown")
    echo "[$ELAPSED/$TIMEOUT segundos] Estado actual: $STATUS"
    
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "⚠️ TIMEOUT: cloud-init tomó más de 15 minutos"
    echo "Intentando continuar de todos modos..."
fi

# Esperar a que se liberen los locks de apt/dpkg
echo ""
echo "⏳ Esperando a que se liberen los locks de apt..."
TIMEOUT=300  # 5 minutos
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
    if check_apt_locks; then
        echo "✅ Locks de apt liberados"
        break
    fi
    
    echo "[$ELAPSED/$TIMEOUT segundos] Esperando a que apt se libere..."
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "⚠️ TIMEOUT: apt aún está bloqueado"
    echo "Procesos que están usando apt:"
    sudo lsof /var/lib/dpkg/lock-frontend 2>/dev/null || true
    sudo lsof /var/lib/apt/lists/lock 2>/dev/null || true
fi

# Verificar que Docker esté instalado
echo ""
echo "🐳 Verificando Docker..."
if command -v docker &> /dev/null; then
    echo "✅ Docker instalado: $(docker --version)"
    echo "✅ Docker Compose: $(docker compose version)"
else
    echo "❌ ERROR: Docker no está instalado"
    exit 1
fi

# Verificar que Docker esté funcionando
if sudo docker info &> /dev/null; then
    echo "✅ Docker está funcionando correctamente"
else
    echo "⚠️ Docker está instalado pero no responde, reiniciando servicio..."
    sudo systemctl restart docker
    sleep 5
    if sudo docker info &> /dev/null; then
        echo "✅ Docker reiniciado exitosamente"
    else
        echo "❌ ERROR: Docker no responde"
        exit 1
    fi
fi

# Verificar permisos del usuario ubuntu
echo ""
echo "👤 Verificando permisos del usuario..."
if groups ubuntu | grep -q docker; then
    echo "✅ Usuario 'ubuntu' está en el grupo docker"
else
    echo "⚠️ Añadiendo usuario ubuntu al grupo docker..."
    sudo usermod -aG docker ubuntu
    echo "✅ Usuario añadido al grupo docker"
fi

# Verificar firewall
echo ""
echo "🔥 Verificando firewall..."
if sudo iptables -L INPUT -n | grep -q "dpt:80"; then
    echo "✅ Puerto 80 está abierto"
else
    echo "⚠️ Puerto 80 no está configurado"
fi

if sudo iptables -L INPUT -n | grep -q "dpt:5000"; then
    echo "✅ Puerto 5000 está abierto"
else
    echo "⚠️ Puerto 5000 no está configurado"
fi

# Verificar directorio de deploy
echo ""
echo "📁 Verificando directorios..."
if [ -d "/home/ubuntu/deploy" ]; then
    echo "✅ Directorio /home/ubuntu/deploy existe"
else
    echo "⚠️ Creando directorio /home/ubuntu/deploy..."
    mkdir -p /home/ubuntu/deploy
    mkdir -p /home/ubuntu/deploy/scripts
fi

# Mostrar logs de cloud-init si hay errores
if ! check_cloud_init; then
    echo ""
    echo "⚠️ Mostrando últimas líneas del log de cloud-init:"
    sudo tail -50 /var/log/cloud-init-output.log || true
    sudo tail -50 /var/log/cloud-init-custom.log 2>/dev/null || true
fi

echo ""
echo "=========================================="
echo "✅ VM lista para recibir despliegue"
echo "=========================================="