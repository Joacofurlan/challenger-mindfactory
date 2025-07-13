# app/Dockerfile
FROM node:18-alpine

# Crear directorio
WORKDIR /app

# Copiar dependencias y construir
COPY package*.json ./
RUN npm install

# Copiar el resto del código
COPY . .

# Instalar curl y certificados (para debug desde el contenedor)
RUN apk add --no-cache curl ca-certificates

# Exponer puerto
EXPOSE 80

# Comando principal
CMD ["node", "redis.js"]
