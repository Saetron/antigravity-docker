# AGENTS.md

Welcome to the **Antigravity Remote Desktop Container** repository. This document provides contextual guidelines, operational workflows, and architecture references for AI agents (e.g., Antigravity, Gemini, Claude, Codex) interacting with or maintaining this codebase.

---

## 🎯 Repository Overview

This repository provides a containerized, lightweight Linux workstation configured with:
- **Base OS**: Debian 12 (Bookworm) Slim.
- **Desktop & WebUI**: XFCE4 desktop served via HTML5 in-browser noVNC (`http://localhost:8080`).
- **Core Tools**: Google Chrome / Chromium (with container sandbox wrappers), Google Antigravity CLI (`agy`), GitHub CLI (`gh`), Git & Git LFS.
- **Development Tooling**: Python 3 (`python3`, `pip`, `venv`, `build-essential`) with unrestricted package installation.
- **Remote Access**: Background remote control daemon (`agy remote-control serve`), OpenSSH server (`port 2222`), and direct VNC (`port 5900`).
- **Hardware Acceleration**: Optional NVIDIA GPU pass-through via Docker Compose v2.

---

## 📁 Repository Structure

```
├── VERSION                     # Container release version (1.1.0)
├── Dockerfile                  # Multi-architecture container image definition
├── docker-compose.yml          # Core service definition and volume mappings
├── docker-compose.gpu.yml      # NVIDIA GPU device reservation override
├── .env.example                # Template of environment variables
├── .gitignore                  # Git tracking rules (ignores secrets & volume data)
├── .dockerignore               # Build context filtering
├── assets/                     # Desktop launcher shortcuts (.desktop files)
│   ├── antigravity.desktop
│   └── google-chrome.desktop
├── config/                     # Supervisor daemon process definitions
│   └── supervisord.conf
├── scripts/                    # Container bootstrapper & lifecycle scripts
│   ├── entrypoint.sh           # Main container entrypoint & permission handler
│   ├── install-antigravity.sh  # Official Antigravity CLI installer
│   ├── install-chrome.sh       # Multi-arch Chrome/Chromium installer & wrapper
│   └── run-antigravity-remote.sh # Background daemon runner for agy remote-control
├── projects/                   # Default host mount directory for project data
└── workspace/                  # Default host mount directory for working files
```

---

## ⚙️ Service Architecture & Supervision

The container uses **Supervisord** (`/usr/bin/supervisord`) to run multiple coordinated processes:

| Priority | Service | Command / Description |
|---|---|---|
| `10` | `xvfb` | Virtual X11 display server on `:1` |
| `20` | `xfce4` | XFCE4 desktop session run as user `antigravity` |
| `30` | `x11vnc` | VNC server attached to `:1` (port 5900) |
| `40` | `websockify` | WebSocket-to-VNC proxy serving noVNC web assets (port 8080) |
| `50` | `sshd` | OpenSSH daemon (port 22 inside container, host port 2222) |
| `60` | `antigravity-remote` | Runs `agy remote-control serve` in the background |

Supervisord logs are written to `/var/log/supervisor/`.

---

## 🛠️ Common Agent Operations

### 1. Building and Running the Container

```bash
# Standard build & run
docker compose up -d --build

# Run with NVIDIA GPU acceleration
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d --build

# Check running container status
docker compose ps

# View service logs
docker compose logs -f antigravity-remote
```

### 2. Executing Commands Inside the Running Container

```bash
# Open interactive bash session as the antigravity user
docker compose exec antigravity-remote bash

# Run commands as root (for troubleshooting)
docker compose exec -u root antigravity-remote bash

# Check supervisor service status
docker compose exec antigravity-remote supervisorctl status
```

### 3. Testing GPU Capabilities

```bash
# Check NVIDIA GPU detection
docker compose exec antigravity-remote nvidia-smi

# Check OpenGL rendering
docker compose exec antigravity-remote glxinfo | grep -i "OpenGL renderer"

# Verify PyTorch CUDA support
docker compose exec antigravity-remote python3 -c "import torch; print(torch.cuda.is_available())"
```

---

## 🔒 Security & Best Practices for Agents

1. **Non-Root User**: The main developer user is `antigravity` (UID `1000`, GID `1000`) with passwordless `sudo`. Do not change the primary user to root for development processes.
2. **Persistence**:
   - Project repositories belong in `/projects` (mounted from host `${PROJECT_DATA_PATH:-./projects}`).
   - User configs and dotfiles reside in `/home/antigravity` (persisted via the `antigravity_home` named volume).
3. **Browser Sandboxing**: Google Chrome and Chromium must run with `--no-sandbox` and `--disable-dev-shm-usage` inside the container unless run with privileged user namespaces. Always maintain the wrapper scripts in `/usr/local/bin/google-chrome`.
4. **Shell Scripting**: All scripts in `scripts/` must be executable (`chmod +x`) and include strict error handling (`set -e` or `set -euo pipefail`).
