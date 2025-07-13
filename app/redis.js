const express = require("express");
const redis = require("redis");
const app = express();
const port = 80;

// 🔍 Log de variables de entorno usadas
console.log("Conectando a Redis con:");
console.log("HOST:", process.env.REDIS_HOST);
console.log("PORT:", process.env.REDIS_PORT);
console.log("TLS:", true);

// 🔐 Cliente Redis TLS (ElastiCache en modo encriptado)
const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    tls: true
  }
});

// Log de errores del cliente Redis
client.on("error", (err) => {
  console.error("❌ Redis Client Error:", err);
});

// Inicio de conexión
client.connect().catch(console.error);

// Endpoint principal
app.get("/", async (req, res) => {
  console.log("🔵 Recibido GET /");
  try {
    await client.set("hello", "world");
    const value = await client.get("hello");
    console.log("✅ Valor leído desde Redis:", value);
    res.send(`Hello from Redis: ${value}`);
  } catch (err) {
    console.error("❌ Error accediendo a Redis:", err);
    res.status(500).send("Redis error");
  }
});

// Levanta el servidor
app.listen(port, () => {
  console.log(`🚀 App running on port ${port}`);
});
