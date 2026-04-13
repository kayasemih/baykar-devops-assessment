FROM mongo:6.0.27-jammy

# Keep MongoDB on the 6.x line to avoid a major-version data upgrade while
# still patching the image packages we control.
RUN apt-get update \
  && apt-get install --yes --no-install-recommends --only-upgrade gpgv \
  && sed -i 's|exec gosu mongodb "$BASH_SOURCE" "$@"|exec setpriv --reuid mongodb --regid mongodb --clear-groups -- "$BASH_SOURCE" "$@"|' /usr/local/bin/docker-entrypoint.sh \
  && rm -f /usr/local/bin/gosu \
    /usr/bin/bsondump \
    /usr/bin/mongodump \
    /usr/bin/mongoexport \
    /usr/bin/mongofiles \
    /usr/bin/mongoimport \
    /usr/bin/mongorestore \
    /usr/bin/mongostat \
    /usr/bin/mongotop \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 27017

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=5 \
  CMD echo 'db.adminCommand("ping").ok' | mongosh --quiet || exit 1
