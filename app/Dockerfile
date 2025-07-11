FROM node:20-alpine

WORKDIR /app
COPY redis.js .

RUN npm install redis

CMD ["node", "redis.js"]
