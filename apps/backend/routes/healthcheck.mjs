import express from "express";
import { pingDatabase } from "../db/conn.mjs";

const router = express.Router();

router.get("/healthcheck/", (_req, res) => {
  res.status(200).json({
    status: "ok",
    message: "OK",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

router.get("/readyz/", async (_req, res) => {
  try {
    await pingDatabase();
    res.status(200).json({
      status: "ready",
      database: "up",
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Readiness check failed", error);
    res.status(503).json({
      status: "degraded",
      database: "down",
      message: "Database unavailable",
      timestamp: new Date().toISOString(),
    });
  }
});

export default router;
