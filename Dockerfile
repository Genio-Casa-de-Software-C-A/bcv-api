FROM denoland/deno:latest

WORKDIR /app

# Prefer not to run as root; ensure /app is owned by deno user
COPY --chown=deno:deno deno.json deno.lock ./
COPY --chown=deno:deno main.ts ./

USER deno

# Cache dependencies
RUN deno cache main.ts

# Expose default port
EXPOSE 3000

ENV PORT=3000

# Run the server. Note: --unsafely-ignore-certificate-errors is required for BCV's SSL certificate
CMD ["run", "--allow-net", "--allow-env", "--unsafely-ignore-certificate-errors=bcv.org.ve,www.bcv.org.ve", "main.ts"]
