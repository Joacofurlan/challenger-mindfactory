const redis = require("redis");
const client = redis.createClient({
  socket: {
    host: "redis-service.default.svc.cluster.local",
    port: 6379
  }
});

client.connect()
  .then(() => {
    return client.set("hello", "world");
  })
  .then(() => {
    return client.get("hello");
  })
  .then(value => {
    console.log("Redis value:", value);
  })
  .catch(err => console.error("Redis error", err));
