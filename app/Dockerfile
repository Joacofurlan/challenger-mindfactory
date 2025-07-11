FROM node:20-alpine AS builder
WORKDIR /app
COPY index.html .
COPY redis.js .
RUN npm install redis

FROM nginx:alpine
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html
COPY --from=builder /app/redis.js /usr/share/nginx/html/redis.js
