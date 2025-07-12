# app/Dockerfile
FROM node:18-alpine

# Crear directorio de la app
WORKDIR /app

# Copiar dependencias y archivos
COPY package*.json ./
RUN npm install

COPY . .

# Exponer puerto
EXPOSE 80

# Comando de inicio
CMD ["node", "redis.js"]