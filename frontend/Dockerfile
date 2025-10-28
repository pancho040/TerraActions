# Multi-stage build para Frontend (Vite/React)

# ===================================
# STAGE 1: Build de la aplicación
# ===================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar todo el código fuente
COPY . .

# Argumento para la URL del backend (se pasa desde GitHub Actions)
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# Build de la aplicación de producción
RUN npm run build

# ===================================
# STAGE 2: Servidor Nginx
# ===================================
FROM nginx:alpine

# Copiar el build desde el stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 80
EXPOSE 80

# Health check para Docker
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

# Nginx se ejecuta automáticamente con la imagen base
CMD ["nginx", "-g", "daemon off;"]