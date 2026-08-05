#!/bin/sh

# Railway volume at /srv is empty on first boot — ensure the root dir exists
ROOT_DIR="${ROOT:-/srv}"
DB_FILE="${FB_DATABASE:-/srv/filebrowser.db}"

mkdir -p "$ROOT_DIR" 2>/dev/null || true
mkdir -p "$(dirname "$DB_FILE")" 2>/dev/null || true

# --noauth is required: Railway's edge WAF (hikari) blocks POST to /api/login,
# so the login API is never called. Auth can be configured via the admin UI.
exec filebrowser --address=0.0.0.0 --port="${PORT:-8080}" \
  --root="$ROOT_DIR" --database="$DB_FILE" --noauth
