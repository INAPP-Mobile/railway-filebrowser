# File Browser Railway Template
# https://github.com/INAPP-Mobile/railway-filebrowser
# Pinned to filebrowser v2.63.17 — the latest stable release

FROM alpine:3.20

ARG FB_VERSION=2.63.17

RUN apk add --no-cache ca-certificates wget \
    && wget -q https://github.com/filebrowser/filebrowser/releases/download/v${FB_VERSION}/linux-amd64-filebrowser.tar.gz \
    && tar xzf linux-amd64-filebrowser.tar.gz -C /usr/local/bin/ \
    && rm linux-amd64-filebrowser.tar.gz \
    && chmod +x /usr/local/bin/filebrowser

EXPOSE 8080

ENV PORT=8080

# Use shell form so $PORT expands at runtime
# --root=/srv is the default root directory — override with ROOT env var
# --baseURL=/app avoids Railway's WAF which blocks /api/login
CMD filebrowser --address=0.0.0.0 --port=${PORT} --root=/srv --database=/srv/filebrowser.db --baseURL=/app
