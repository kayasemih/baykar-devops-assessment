import cors from "cors";
import express from "express";
import { Counter, Histogram, Registry, collectDefaultMetrics } from "prom-client";
import "./loadEnvironment.mjs";
import healthcheck from "./routes/healthcheck.mjs";
import records from "./routes/record.mjs";

const app = express();
const metricsRegistry = new Registry();

collectDefaultMetrics({
  register: metricsRegistry,
  prefix: "backend_",
});

const requestCounter = new Counter({
  name: "http_requests_total",
  help: "Total HTTP requests handled by the backend",
  labelNames: ["method", "route", "status_code"],
  registers: [metricsRegistry],
});

const requestDuration = new Histogram({
  name: "http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.05, 0.1, 0.25, 0.5, 1, 2, 5],
  registers: [metricsRegistry],
});

app.disable("x-powered-by");
app.use(cors());
app.use(express.json());
app.use((req, res, next) => {
  const stopTimer = requestDuration.startTimer();

  res.on("finish", () => {
    const route = req.route?.path
      ? `${req.baseUrl || ""}${req.route.path}`
      : req.originalUrl.split("?")[0];
    const labels = {
      method: req.method,
      route,
      status_code: String(res.statusCode),
    };

    requestCounter.inc(labels);
    stopTimer(labels);
  });

  next();
});

app.use(healthcheck);
app.use("/record", records);

app.get("/metrics", async (_req, res) => {
  res.set("Content-Type", metricsRegistry.contentType);
  res.end(await metricsRegistry.metrics());
});

export default app;
