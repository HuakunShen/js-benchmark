import app from "./hono";

Bun.serve({
  fetch: app.fetch,
  port: 3000,
});
