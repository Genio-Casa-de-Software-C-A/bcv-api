FROM denoland/deno:2.1.9

WORKDIR /app

# Prefer not to run as root
USER deno

# Cache dependencies
COPY deno.json deno.lock ./
RUN deno install

# Copy application source
COPY main.ts ./

# Expose default port
EXPOSE 3000

ENV PORT=3000

# Run the server. Note: --unsafely-ignore-certificate-errors is required for BCV's SSL certificate
CMD ["run", "--allow-net", "--allow-env", "--unsafely-ignore-certificate-errors=bcv.org.ve,www.bcv.org.ve", "main.ts"]
