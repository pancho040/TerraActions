#!/bin/bash
# Cloud-init para WebBibliotecaTerra: instalación de Docker y despliegue automático
# Ubuntu 22.04 LTS

# -----------------------------
# 1. Actualizar paquetes base
# -----------------------------
sudo apt-get update -y
sudo apt-get upgrade -y

# -----------------------------
# 2. Instalar Docker y complementos
# -----------------------------
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -----------------------------
# 3. Añadir usuario 'ubuntu' al grupo docker
# -----------------------------
if id -u ubuntu >/dev/null 2>&1; then
    sudo usermod -aG docker ubuntu
fi

# -----------------------------
# 4. Habilitar y arrancar Docker
# -----------------------------
sudo systemctl enable docker
sudo systemctl start docker

# -----------------------------
# 5. Crear carpeta para la app
# -----------------------------
sudo mkdir -p /opt/webbibliotecaterra
sudo chown ubuntu:ubuntu /opt/webbibliotecaterra

# -----------------------------
# 6. Crear archivo docker-compose.yml dinámico
# -----------------------------
cat > /opt/webbibliotecaterra/docker-compose.yml <<EOF
version: "3.8"

services:
  backend:
    image: ${DOCKER_USER}/webbiblioteca-backend:latest
    container_name: webbiblioteca-backend
    ports:
      - "5000:5000"
    environment:
      - PORT=5000
      - NODE_ENV=production
      - FRONTEND_URL=http://localhost
      - SUPA_BASE_URL=${SUPA_BASE_URL}
      - SUPA_ANON_KEY=${SUPA_ANON_KEY}
      - JWT_SECRET=${JWT_SECRET}
    restart: always
    networks:
      - webbiblioteca-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    image: ${DOCKER_USER}/webbiblioteca-frontend:latest
    container_name: webbiblioteca-frontend
    ports:
      - "80:80"
    environment:
      - VITE_API_URL=http://backend:5000
    restart: always
    networks:
      - webbiblioteca-network
    depends_on:
      backend:
        condition: service_healthy

networks:
  webbiblioteca-network:
    driver: bridge
EOF

sudo chown ubuntu:ubuntu /opt/webbibliotecaterra/docker-compose.yml

# -----------------------------
# 7. Crear servicio systemd para ejecución automática
# -----------------------------
sudo bash -c 'cat > /etc/systemd/system/webbibliotecaterra.service <<EOL
[Unit]
Description=WebBibliotecaTerra Docker Compose Service
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/webbibliotecaterra
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL'

sudo systemctl daemon-reexec
sudo systemctl enable webbibliotecaterra.service
sudo systemctl start webbibliotecaterra.service

# -----------------------------
# 8. Configurar firewall (iptables)
# -----------------------------
echo "🔧 Configurando firewall..."

if ! dpkg -l | grep -q iptables-persistent; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
fi

# Limpiar reglas previas
sudo iptables -F

# Reglas básicas
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT   # SSH
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT   # Frontend
sudo iptables -A INPUT -p tcp --dport 5000 -j ACCEPT # Backend

# Guardar reglas permanentemente
sudo netfilter-persistent save

# Mostrar reglas actuales
sudo iptables -L INPUT -n --line-numbers

echo "✅ Instalación completa: Docker, Docker Compose y firewall configurados."
echo "✅ Frontend disponible en puerto 80 y Backend en puerto 5000."
