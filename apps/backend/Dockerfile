# ============================================================
# Express.js Backend
# ============================================================
FROM node:18-alpine AS deps

WORKDIR /app

# Install deps first for layer caching
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --silent

FROM node:18-alpine

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

# Copy application source
COPY --chown=node:node . .

# Don't run as root — if the container gets compromised,
# the attacker only has unprivileged access.
# node:18-alpine already has a 'node' user built in.
USER node

EXPOSE 5050

# Docker-level health check — used by docker-compose's 'depends_on: condition: service_healthy'
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5050/healthcheck/ || exit 1

CMD ["node", "server.mjs"]
