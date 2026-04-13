FROM mongo:6.0

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=5 \
  CMD echo 'db.adminCommand("ping").ok' | mongosh --quiet || exit 1
