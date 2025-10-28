# Dockerfile para Backend (Node.js + TypeScript)
FROM node:20-alpine

# Instalar dependencias del sistema necesarias para compilación
RUN apk add --no-cache \
    bash \
    build-base \
    python3 \
    wget

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias de producción y desarrollo (necesarias para compilar)
RUN npm ci

# Copiar todo el código fuente
COPY . .

# Compilar TypeScript
RUN npx tsc

# Eliminar dependencias de desarrollo para reducir tamaño
RUN npm prune --production

# Exponer puerto del backend
EXPOSE 5000

# Variables de entorno por defecto
ENV PORT=5000
ENV NODE_ENV=production

# Health check para Docker
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5000/api/health || exit 1

# Comando para ejecutar la aplicación
CMD ["node", "dist/src/index.js"]