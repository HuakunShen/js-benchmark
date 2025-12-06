import elysia from "./elysia";

Bun.serve({
  fetch: elysia.fetch,
  port: 3000,
});
