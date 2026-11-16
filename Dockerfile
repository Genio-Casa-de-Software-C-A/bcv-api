FROM denoland/deno:latest

# Install curl for container health checks
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Ensure /app is owned by deno user
RUN chown -R deno:deno /app

COPY --chown=deno:deno deno.json deno.lock ./
COPY --chown=deno:deno main.ts ./

USER deno

# Cache dependencies
RUN deno cache main.ts

# Expose default port
EXPOSE 3000

ENV PORT=3000

# Docker healthcheck using curl
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:${PORT:-3000}/health || exit 1

# Run the server. Note: --unsafely-ignore-certificate-errors is required for BCV's SSL certificate
CMD ["run", "--allow-net", "--allow-env", "--unsafely-ignore-certificate-errors=bcv.org.ve,www.bcv.org.ve", "main.ts"]
