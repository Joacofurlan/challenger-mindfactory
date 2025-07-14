const express = require("express");
const redis = require("redis");
const path = require("path");

const app = express();
const port = 80;

console.log("📦 Starting app...");

const client = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    tls: true,
    servername: process.env.REDIS_HOST
  }
});

client.on("error", (err) => {
  console.error("❌ Redis Client Error", err);
});

client.connect()
  .then(() => console.log("✅ Redis connected"))
  .catch(err => console.error("❌ Redis connect error:", err));

// Servir el index.html
app.use(express.static(path.join(__dirname)));

// Endpoint para probar Redis
app.get("/api", async (req, res) => {
  console.log("📥 GET /api request received");
  try {
    await client.set("hello", "world");
    const value = await client.get("hello");
    console.log("🔁 Valor leído desde Redis:", value);
    res.json({ message: `Hello from Redis: ${value}` });
  } catch (err) {
    console.error("❌ Error en Redis:", err);
    res.status(500).json({ error: "Redis error" });
  }
});

app.listen(port, () => {
  console.log(`🚀 App running on port ${port}`);
});
