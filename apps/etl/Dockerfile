# ============================================================
# Python ETL Job
# ============================================================
FROM python:3.13-alpine AS builder

WORKDIR /wheels

RUN apk upgrade --no-cache

COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

FROM python:3.13-alpine

WORKDIR /app

RUN apk upgrade --no-cache

# Install dependencies from pre-built wheels to keep the final image small
COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && rm -rf /wheels

# Copy the ETL script
COPY ETL.py .

# Run as non-root for security
RUN adduser -D appuser && chown -R appuser:appuser /app
USER appuser

CMD ["python", "ETL.py"]
