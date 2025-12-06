import { serve } from "@hono/node-server";
import app from "./hono";

serve(app);
