#!/bin/sh
set -e

DOMAIN=${DOMAIN:-"daim-lab"}
EMAIL=${EMAIL:-"cotidie@kaist.ac.kr"}

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
  echo "ERROR: CLOUDFLARE_API_TOKEN environment variable is not set"
  exit 1
fi

CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
CF_CREDS="/etc/letsencrypt/cloudflare.ini"
mkdir -p "$(dirname "$CF_CREDS")"
printf 'dns_cloudflare_api_token = %s\n' "$CLOUDFLARE_API_TOKEN" > "$CF_CREDS"
chmod 600 "$CF_CREDS"

if [ ! -f "$CERT_PATH" ]; then
  echo "No certificate found. Requesting via DNS-01..."
  certbot certonly \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$CF_CREDS" \
    --dns-cloudflare-propagation-seconds 30 \
    -d "$DOMAIN" \
    -d "*.$DOMAIN"
else
  echo "Certificate found. Attempting renewal if needed..."
  certbot renew --quiet
fi

echo "Starting nginx..."
( while true; do sleep 12h; certbot renew --quiet; nginx -s reload; done ) &
exec nginx -g "daemon off;"
