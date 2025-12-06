import { node } from "@elysiajs/node";
import app from "./elysia";
import { Elysia } from "elysia";

const newApp = new Elysia({ adapter: node() }).use(app);
newApp.listen(3000);
