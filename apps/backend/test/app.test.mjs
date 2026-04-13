import assert from "node:assert/strict";
import { createServer } from "node:http";
import test from "node:test";
import app from "../app.mjs";

async function withServer(run) {
  const server = createServer(app);

  await new Promise((resolve) => {
    server.listen(0, "127.0.0.1", resolve);
  });

  const { port } = server.address();

  try {
    await run(`http://127.0.0.1:${port}`);
  } finally {
    await new Promise((resolve, reject) => {
      server.close((error) => {
        if (error) {
          reject(error);
          return;
        }

        resolve();
      });
    });
  }
}

test("healthcheck returns OK", async () => {
  await withServer(async (baseUrl) => {
    const response = await fetch(`${baseUrl}/healthcheck/`);
    const body = await response.json();

    assert.equal(response.status, 200);
    assert.equal(body.message, "OK");
  });
});

test("metrics endpoint exposes HTTP metrics", async () => {
  await withServer(async (baseUrl) => {
    await fetch(`${baseUrl}/healthcheck/`);

    const response = await fetch(`${baseUrl}/metrics`);
    const body = await response.text();

    assert.equal(response.status, 200);
    assert.match(body, /http_requests_total/);
    assert.match(body, /http_request_duration_seconds_bucket/);
  });
});
