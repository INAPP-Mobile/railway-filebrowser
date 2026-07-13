#!/bin/sh

# Railway volume at /srv is empty on first boot — ensure db dir exists
mkdir -p /srv 2>/dev/null || true

exec filebrowser --address=0.0.0.0 --port="${PORT:-8080}" --root=/srv --database=/srv/filebrowser.db --noauth