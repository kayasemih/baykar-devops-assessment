# ============================================================
# Python ETL Job
# ============================================================
FROM python:3.11-slim AS builder

WORKDIR /wheels

COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

# Install dependencies from pre-built wheels to keep the final image small
COPY --from=builder /wheels /wheels
COPY requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt && rm -rf /wheels

# Copy the ETL script
COPY ETL.py .

# Run as non-root for security
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

CMD ["python", "ETL.py"]
