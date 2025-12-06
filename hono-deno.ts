import app from "./hono";

Deno.serve({ port: 3000 }, app.fetch);
