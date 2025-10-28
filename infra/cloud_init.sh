#!/bin/bash
# Cloud-init para WebBibliotecaTerra: Docker + Docker Compose para Backend y Frontend
# Ubuntu 22.04

# -----------------------------
# 1. Actualizar paquetes base
# -----------------------------
sudo apt-get update -y
sudo apt-get upgrade -y

# -----------------------------
# 2. Instalar Docker
# -----------------------------
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

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
# 6. Configurar Docker Compose
# -----------------------------
cat > /opt/webbibliotecaterra/docker-compose.yml <<'EOF'
version: "3.9"

services:
  backend:
    image: tu_usuario_dockerhub/backend:latest
    container_name: webbiblioteca_backend
    restart: always
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      # Agrega aquí tus variables de entorno del backend

  frontend:
    image: tu_usuario_dockerhub/frontend:latest
    container_name: webbiblioteca_frontend
    restart: always
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:5000
      # Agrega aquí tus variables de entorno del frontend
EOF

# -----------------------------
# 7. Levantar contenedores al iniciar la VM
# -----------------------------
sudo chown ubuntu:ubuntu /opt/webbibliotecaterra/docker-compose.yml
sudo bash -c "cat > /etc/systemd/system/webbibliotecaterra.service <<'EOL'
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
EOL"

sudo systemctl daemon-reexec
sudo systemctl enable webbibliotecaterra.service
sudo systemctl start webbibliotecaterra.service

echo "✅ Docker y Docker Compose configurados con Backend y Frontend listos."
