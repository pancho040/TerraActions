#!/bin/bash

# Cloud Init Script para WebBibliotecaTerra - Single VM
# Configura una VM con ambos contenedores (frontend y backend)

set -e

echo "🚀 Iniciando configuración de WebBibliotecaTerra..."

# Actualizar sistema
apt-get update -qq

# Instalar Docker
echo "🐳 Instalando Docker..."
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -qq
apt-get install -y docker-ce docker-ce-cli containerd.io

# Instalar Docker Compose
echo "🐳 Instalando Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Agregar usuario ubuntu al grupo docker
usermod -aG docker ubuntu

# Asegurar que Docker esté corriendo
systemctl enable docker
systemctl start docker

# Configurar firewall
echo "🔥 Configurando firewall..."

# Instalar iptables-persistent
DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent

# Configurar reglas básicas de iptables
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Abrir puertos para frontend y backend
iptables -A INPUT -p tcp --dport 80 -j ACCEPT    # Frontend
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT  # Backend

# Eliminar regla de REJECT de Oracle Cloud si existe
iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited 2>/dev/null || true

# Guardar reglas de firewall
netfilter-persistent save

# Crear directorio para la aplicación
mkdir -p /opt/webbibliotecaterra
cd /opt/webbibliotecaterra

# Crear archivo docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  backend:
    image: ${DOCKER_USER}/webbiblbioteca-backend:latest
    container_name: webbiblbioteca-backend
    ports:
      - "5000:5000"
    environment:
      - PORT=5000
      - NODE_ENV=production
      - FRONTEND_URL=http://localhost:80
      - SUPA_BASE_URL=${SUPA_BASE_URL}
      - SUPA_ANON_KEY=${SUPA_ANON_KEY}
      - JWT_SECRET=${JWT_SECRET}
    restart: always
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    image: ${DOCKER_USER}/webbiblbioteca-frontend:latest
    container_name: webbiblbioteca-frontend
    ports:
      - "80:80"
    environment:
      - VITE_API_URL=http://localhost:5000
    restart: always
    depends_on:
      - backend
EOF

# Crear script de despliegue
cat > deploy.sh << 'EOF'
#!/bin/bash

# Script de despliegue para WebBibliotecaTerra
set -e

echo "🚀 Desplegando WebBibliotecaTerra..."

cd /opt/webbibliotecaterra

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo "⚠️  Creando archivo .env desde variables de entorno..."
    cat > .env << ENVEOF
DOCKER_USER=${DOCKER_USER}
SUPA_BASE_URL=${SUPA_BASE_URL}
SUPA_ANON_KEY=${SUPA_ANON_KEY}
JWT_SECRET=${JWT_SECRET}
ENVEOF
fi

# Limpiar contenedores antiguos
echo "🧹 Limpiando contenedores antiguos..."
docker-compose down || true

# Pull de las imágenes más recientes
echo "📥 Descargando imágenes más recientes..."
docker-compose pull

# Levantar los servicios
echo "🐳 Iniciando contenedores..."
docker-compose up -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 30

# Verificar estado
echo "📊 Estado de los contenedores:"
docker-compose ps

echo "✅ Despliegue completado!"
echo "🌐 Frontend disponible en: http://$(curl -s ifconfig.me)"
echo "🔧 Backend disponible en: http://$(curl -s ifconfig.me):5000"
EOF

chmod +x deploy.sh

# Crear script de verificación
cat > check_ports.sh << 'EOF'
#!/bin/bash

# Script para verificar puertos y conectividad - Single VM

echo "🔍 Verificando configuración de WebBibliotecaTerra..."
echo ""

# Mostrar IP pública
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "No disponible")
echo "🌐 IP Pública: $PUBLIC_IP"
echo ""

# Verificar puertos en escucha
echo "👂 Puertos en escucha:"
ss -tulpn 2>/dev/null | grep -E ':(22|80|5000)' || echo "No se encontraron puertos conocidos"
echo ""

# Verificar reglas de firewall
echo "🔥 Reglas de firewall (iptables):"
iptables -L INPUT -n --line-numbers | grep -E "dpt:(22|80|5000)|ACCEPT.*tcp" | head -10 || echo "No se encontraron reglas"
echo ""

# Verificar contenedores Docker
echo "🐳 Contenedores Docker:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No se pudieron listar contenedores"
echo ""

# Pruebas de conectividad
echo "🧪 Pruebas de conectividad:"

echo "   - Backend (localhost:5000):"
curl -s -o /dev/null -w "     Status: %{http_code}\n" http://localhost:5000/api/health 2>/dev/null || echo "     ❌ Error al conectar al backend"

echo "   - Frontend (localhost:80):"
curl -s -o /dev/null -w "     Status: %{http_code}\n" http://localhost:80 2>/dev/null || echo "     ❌ Error al conectar al frontend"

echo ""
echo "✅ Verificación completada"
echo ""

# Verificar Oracle Cloud Security Lists
echo "💡 RECORDATORIO: Asegúrate de que las Security Lists en Oracle Cloud tengan:"
echo "   - Ingress Rule: 0.0.0.0/0 → TCP → Puerto 80 (Frontend)"
echo "   - Ingress Rule: 0.0.0.0/0 → TCP → Puerto 5000 (Backend)"
echo ""
EOF

chmod +x check_ports.sh

echo ""
echo "✅ Configuración de cloud-init completada!"
echo "📋 Próximos pasos:"
echo "   1. SSH a la VM: ssh ubuntu@<IP_PUBLICA>"
echo "   2. Configurar variables de entorno en /opt/webbibliotecaterra/.env"
echo "   3. Ejecutar: cd /opt/webbibliotecaterra && ./deploy.sh"
echo "   4. Verificar: ./check_ports.sh"