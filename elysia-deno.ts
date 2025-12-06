import app from "./elysia";

Deno.serve({ port: 3000 }, app.fetch);
