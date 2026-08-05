# File Browser Railway Template
# https://github.com/INAPP-Mobile/railway-filebrowser
# Pinned to filebrowser v2.63.17 — the latest stable release
#
# NOTE: Railway's edge WAF (hikari) blocks POST requests to any path
# ending in /api/login. To work around this, File Browser runs with
# --noauth so the login API is never called. Users who need auth can
# configure it via the admin settings UI.

FROM alpine:3.20

ARG FB_VERSION=2.63.23

RUN apk add --no-cache ca-certificates wget \
    && wget -q https://github.com/filebrowser/filebrowser/releases/download/v${FB_VERSION}/linux-amd64-filebrowser.tar.gz \
    && tar xzf linux-amd64-filebrowser.tar.gz -C /usr/local/bin/ \
    && rm linux-amd64-filebrowser.tar.gz \
    && chmod +x /usr/local/bin/filebrowser

EXPOSE 8080

ENV PORT=8080
ENV ROOT=/srv
ENV FB_DATABASE=/srv/filebrowser.db

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]