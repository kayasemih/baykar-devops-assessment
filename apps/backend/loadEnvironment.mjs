import dotenv from "dotenv";

// Try to load from config.env (for local development).
// In Docker/Kubernetes, env vars are injected directly — this is a no-op if the file doesn't exist.
dotenv.config({ path: "./config.env" });
dotenv.config(); // Also check .env as fallback
