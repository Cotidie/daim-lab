FROM nginx:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    openssl \
    gettext-base \
    && pip3 install --break-system-packages --upgrade \
        certbot \
        certbot-dns-cloudflare \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME /etc/letsencrypt
VOLUME /var/www/certbot

RUN mkdir -p /var/www/daim-lab.com

ENTRYPOINT ["/entrypoint.sh"]
