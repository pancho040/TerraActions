# -------------------------------
# Etapa 1: Compilación (build)
# -------------------------------
FROM node:20-alpine AS builder

# Instalar dependencias necesarias para compilar
RUN apk add --no-cache \
    bash \
    build-base \
    python3 \
    wget

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de dependencias
COPY package*.json ./

# Instalar dependencias (incluyendo las de desarrollo)
RUN npm ci

# Copiar todo el código fuente
COPY . .

# Asegurar permisos de ejecución para el compilador TypeScript
RUN chmod +x ./node_modules/.bin/tsc

# Compilar el proyecto TypeScript → JavaScript
RUN ./node_modules/.bin/tsc

# -------------------------------
# Etapa 2: Producción (runtime)
# -------------------------------
FROM node:20-alpine

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar solo lo necesario desde la etapa anterior
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist

# Instalar solo dependencias de producción
RUN npm ci --omit=dev

# Exponer el puerto del backend
EXPOSE 5000

# Variables de entorno
ENV PORT=5000
ENV NODE_ENV=production

# Healthcheck para asegurar que el servicio esté activo
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5000/api/health || exit 1

# Comando de inicio
CMD ["node", "dist/src/index.js"]
