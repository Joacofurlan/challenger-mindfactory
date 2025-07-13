const express = require("express");
const redis = require("redis");
const app = express();
const port = 80;

const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    tls: true // 🟢 CLAVE: Habilita conexión segura con ElastiCache
  }
});

client.connect().catch(console.error);

app.get("/", async (req, res) => {
  try {
    await client.set("hello", "world");
    const value = await client.get("hello");
    res.send(`Hello from Redis: ${value}`);
  } catch (err) {
    console.error(err);
    res.status(500).send("Redis error");
  }
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});
