const redis = require("redis");
const client = redis.createClient({
  socket: {
    host: "redis-service.default.svc.cluster.local",
    port: 6379
  }
});

client.connect()
  .then(() => {
    console.log("Conexión a Redis exitosa");
    return client.set("hello", "world");
  })
  .then(() => {
    console.log("Se escribió en Redis: hello=world");
    return client.get("hello");
  })
  .then(value => {
    console.log("Redis value: ", value); // Esto debería mostrar "world"
  })
  .catch(err => console.error("Redis error: ", err));
