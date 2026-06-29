# File Browser — Railway Template

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/xxxxx)

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
| `FB_USERNAME`  | `admin`    | Default admin username (first run only)     |
| `FB_PASSWORD`  | *(unset)*  | Default admin password (plain text, first run) |

On first startup, File Browser creates an admin user automatically. You can log in with credentials configured via env vars.

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
| `--username`       | `FB_USERNAME` | `admin`      | First user's username                   |
| `--password`       | `FB_PASSWORD` | *(auto-gen)* | First user's password (hashed)          |
| `--noauth`         | —           | `false`       | Disable authentication (not recommended) |
| `--baseurl`        | `FB_BASEURL` | `""`         | Base URL for reverse proxy              |
| `--cache-dir`      | —           | `""`          | File cache directory                    |

### Advanced: Custom Configuration File

File Browser also supports a `.json` or `.yaml` configuration file. Generate one:

```bash
filebrowser config init > filebrowser.json
```

Then mount it at `/srv/filebrowser.json` or use `--config` flag.

## Troubleshooting

### Unable to log in

The default admin credentials are set via `FB_USERNAME` and `FB_PASSWORD`. If these are not set, File Browser generates a random password on first startup. Check your Railway logs for the generated credentials.

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

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/mpapKR)

### Quick Deploy Steps

1. Click the **Deploy to Railway** button above
2. Set `FB_USERNAME` and `FB_PASSWORD` environment variables (optional but recommended)
3. Click **Deploy** — the build takes ~30 seconds
4. Visit your new file browser at the generated `*.up.railway.app` URL

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORT` | No | `8080` | HTTP listen port (Railway sets this automatically) |
| `ROOT` | No | `/srv` | Root directory to serve files from |
| `FB_USERNAME` | No | `admin` | First admin username (ignored if admin already exists) |
| `FB_PASSWORD` | No | _auto-generated_ | Default password on first run — set explicitly for reproducibility |

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
