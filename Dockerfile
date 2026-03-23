# ──────────────────────────────────────
# ISE ACME Certificate Auto-Renewal
# ──────────────────────────────────────
FROM python:3.11-slim

LABEL maintainer="your-email@yourdomain.com"
LABEL description="Automated ACME certificate lifecycle management for Cisco ISE"
LABEL version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/yourusername/ise-acme-automation"

# Set working directory
WORKDIR /app

# Install system dependencies (for nslookup/DNS verification)
RUN apt-get update && \
    apt-get install -y --no-install-recommends dnsutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY ise_acme_automation.py .

# Create directories
RUN mkdir -p /app/logs /app/config

# Non-root user for security
RUN groupadd -r iseacme && useradd -r -g iseacme iseacme
RUN chown -R iseacme:iseacme /app
USER iseacme

# Health check
HEALTHCHECK --interval=60s --timeout=10s --retries=3 \
    CMD python -c "import requests; print('OK')" || exit 1

# Default entrypoint
ENTRYPOINT ["python", "ise_acme_automation.py"]
CMD ["--action", "renew", "--config", "/app/config/config.json"]
