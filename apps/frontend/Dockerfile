# ============================================================
# Stage 1: Build the React application
# ============================================================
# Using node:18-alpine for smaller image size (~120MB vs ~900MB for full node)
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files first — this layer gets cached unless deps change.
# This means if you only change source code, npm install won't re-run.
COPY package.json package-lock.json ./
RUN npm ci --silent

# Now copy source code and build
COPY . .
RUN npm run build

# ============================================================
# Stage 2: Serve with Nginx
# ============================================================
# The final image is just Nginx + static files. No Node.js, no node_modules.
# Result: ~25MB image instead of ~500MB+
FROM nginxinc/nginx-unprivileged:1.25-alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx config (SPA routing + API proxy)
COPY nginx.conf /etc/nginx/conf.d/

# Copy the built React app from stage 1
COPY --from=build /app/build /usr/share/nginx/html

# Nginx runs on port 8080 in the unprivileged image
EXPOSE 8080

# Health check — Nginx returns 200 on /
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
