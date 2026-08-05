# File Browser — Railway Template

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/new/template/industrious-happiness)

Deploy [File Browser](https://github.com/filebrowser/filebrowser) — a web-based file manager — on Railway in minutes.

File Browser provides a file managing interface within a specified directory. Upload, delete, preview, rename, and edit your files through a clean web UI. It supports multiple users, share links, and granular permissions.

## Features

- **Single-file binary** — Go-based, minimal resource usage (~15 MB)
- **Web-based file management** — upload, download, rename, delete, preview
- **Multi-user support** — each user can have their own directory
- **Share links** — create time-limited, password-protected shares
- **Text editor** — edit files directly in the browser
- **Image thumbnails** — automatic preview generation
- **Search** — full-text and filename search
- **Archive support** — upload and extract zip/tar/gz archives

## Architecture

```
                      ┌──────────────┐
                      │   Browser    │
                      └──────┬───────┘
                             │ HTTPS
                      ┌──────▼───────┐
                      │   Railway    │
                      │  Edge Proxy  │
                      └──────┬───────┘
                             │ HTTP :PORT
                      ┌──────▼───────┐
                      │  Filebrowser │
                      │  (Go binary) │
                      │  :$PORT      │
                      ├──────────────┤
                      │  /srv root   │
                      │  (ephemeral) │
                      └──────────────┘
```

> **Note:** File Browser supports a persistent database at `/srv/filebrowser.db`. On Railway, this is ephemeral unless you attach a volume.

## Quick Start

Click the Deploy button above, then configure these environment variables:

| Variable       | Default    | Description                                |
|----------------|------------|--------------------------------------------|
| `PORT`         | `8080`     | HTTP port (Railway sets this automatically) |
| `ROOT`         | `/srv`     | Root directory to serve                     |
| `FB_DATABASE`  | `/srv/filebrowser.db` | Database file path (persisted on volume) |

> **Note:** This deployment runs File Browser in `--noauth` mode because Railway's edge WAF blocks the login API (`POST /api/login`). There is no username/password login on first boot — anyone with the URL can access files. You can restrict access with a [Railway TCP Proxy + auth proxy](https://railway.com/docs/reference/tcp-proxies) or enable auth via the admin settings UI after deploy.

## Local Development

```bash
# Clone the repository
git clone git@github.com:INAPP-Mobile/railway-filebrowser.git
cd railway-filebrowser

# Build the Docker image
podman build -t railway-filebrowser .

# Run the container
podman run -d \
  --name filebrowser \
  -p 8080:8080 \
  -e PORT=8080 \
  -v /path/to/your/files:/srv \
  railway-filebrowser

# Visit http://localhost:8080
```

## Configuration

File Browser supports environment variables for configuration. These are passed as CLI flags:

| Flag               | Environment | Default       | Description                             |
|--------------------|-------------|---------------|-----------------------------------------|
| `--port`           | `PORT`      | `8080`        | HTTP listen port                        |
| `--address`        | —           | `0.0.0.0`     | Bind address                            |
| `--root`           | `ROOT`      | `/srv`        | Root directory to serve                 |
| `--database`       | `FB_DATABASE` | `/srv/filebrowser.db` | Database path                 |
| `--noauth`         | —           | `true`        | Auth disabled (required for Railway WAF) |
| `--baseurl`        | `FB_BASEURL` | ""          | Base URL for reverse proxy              |
| `--cache-dir`      | —           | `""`          | File cache directory                    |

### Advanced: Custom Configuration File

File Browser also supports a `.json` or `.yaml` configuration file. Generate one:

```bash
filebrowser config init > filebrowser.json
```

Then mount it at `/srv/filebrowser.json` or use `--config` flag.

## Troubleshooting

### File access is wide open (no login)

This deployment intentionally runs in `--noauth` mode because Railway's edge WAF blocks the login API (`POST /api/login`). Anyone with the deploy URL can read and write files in `ROOT`. Restrict access with a [Railway TCP Proxy + auth proxy](https://railway.com/docs/reference/tcp-proxies) in front, or mount a [VPN](https://railway.com/docs/reference/vpn) for private access.

### Files not visible

Ensure the root directory (`/srv`) contains files. File Browser serves the contents of this directory. If you've attached a Railway volume, mount it at `/srv`.

### Port conflict

Railway sets the `PORT` environment variable automatically. The Dockerfile binds to `${PORT}`. If you see EADDRINUSE errors, ensure no other service is using the port.

### Slow thumbnails

Image processing is CPU-intensive. Adjust the `--img-processors` flag if needed (default: 4).

## Dependencies for File Browser

### Deployment Dependencies

- [Railway Account](https://railway.app) — hosting platform
- [GitHub Account](https://github.com) — source code hosting

### Technical Dependencies

- Go binary — self-contained, no runtime dependencies
- Alpine Linux 3.20 — base image (~5 MB)

## Deploy and Host

Deploy File Browser to Railway in one click. No local environment setup required — the containerized image includes everything needed for your file management needs on production-grade infrastructure with automatic HTTPS.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/new/template/industrious-happiness)

### Quick Deploy Steps

1. Click the **Deploy to Railway** button above
2. Click **Deploy** — the build takes ~30 seconds
3. Visit your new file browser at the generated `*.up.railway.app` URL

> **Note:** This deployment runs in `--noauth` mode so the login API is never used (Railway's edge WAF blocks it). Restrict public access with a [TCP Proxy + auth proxy](https://railway.com/docs/reference/tcp-proxies) if needed.

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | No | `8080` | HTTP listen port (Railway sets this automatically) |
| `ROOT` | No | `/srv` | Root directory to serve files from |
| `FB_DATABASE` | No | `/srv/filebrowser.db` | Embedded database file path (persisted on volume) |

### Persistent Storage

File Browser stores its SQLite database at `/srv/filebrowser.db` by default. To persist data across deployments, attach a [Railway Volume](https://railway.com/docs/resources/volumes) and mount it at `/srv`. The volume preserves your files and the embedded database automatically.

## About Hosting

### How It Works on Railway

File Browser runs inside a single Alpine-based container (Alpine 3.20, ~30 MB). The Dockerfile downloads the File Browser Go binary (v2.63.17) at build time and configures it to listen on the port assigned by Railway via the `PORT` environment variable. A health check pings `/health` to verify the container is serving requests.

The service is self-contained — no external database, cache, or dependencies are needed. All user data (files + metadata) lives inside the container's filesystem at `/srv`.

### Resource Profile

| Metric | Value |
|--------|-------|
| Image size | ~30 MB uncompressed |
| RAM usage | 15–50 MB idle (~100 MB under heavy file operations) |
| CPU usage | Negligible idle; burst during thumbnail generation |
| Startup time | ~2 seconds after image pulled |

## Why Deploy

- **Zero-config deployment** — one-click deploy, no Docker knowledge required
- **No external dependencies** — single binary, SQLite for metadata, no Redis or Postgres
- **Automatic HTTPS** — Railway provisions TLS certificates on your `*.up.railway.app` domain
- **Persistent storage** — attach a volume to keep files and the database across deployments
- **Lightweight** — runs perfectly on the smallest Railway Hobby tier

## Common Use Cases

- **Personal media server** — store and access photos, documents, and videos from anywhere
- **Team file sharing** — share folders via public links with time-limited, password-protected access
- **Backup destination** — serve as a remote backup location for files from other servers or desktops
- **Static site content** — host images, PDFs, and assets for Jekyll, Hugo, or custom static sites
- **Cross-device sync** — replace Dropbox/Google Drive with your self-hosted file manager

## License

This template is licensed under the [MIT License](LICENSE).

File Browser itself is licensed under [Apache License 2.0](https://github.com/filebrowser/filebrowser/blob/master/LICENSE).
