# Antigravity Remote Desktop Container

A lightweight, containerized Linux desktop development environment equipped with **Google Chrome**, **Antigravity CLI (`agy`)**, **GitHub CLI (`gh`)**, **Git**, **Python 3**, and an in-browser **noVNC WebUI**.

---

## 🚀 Features

- **Lightweight OS & Desktop**: Debian 12 (Bookworm) base with an XFCE4 desktop environment (~250MB idle RAM).
- **In-Browser WebUI (noVNC)**: Access the full desktop environment from any browser at `http://localhost:8080` without installing local VNC clients.
- **Google Chrome / Chromium**: Pre-installed and configured with container sandbox workarounds (`--no-sandbox`, `--disable-dev-shm-usage`).
- **Google Antigravity CLI (`agy` & `antigravity`)**: Pre-installed in `/usr/local/bin` with automatic background updates, a desktop shortcut, and **automated startup in Remote Mode** (`agy remote-control serve`).
- **Remote Mode Daemon**: Automatically starts up with the container, enabling remote control from web dashboards and the AGY Remote app.
- **Interactive Auto-launch**: Automatically launches an interactive terminal on the desktop GUI upon startup.

- **GitHub CLI (`gh`) & Git**: Authenticate and manage repositories directly inside the container.
- **Extensible Python & Development Tooling**: `python3`, `pip`, `venv`, and `build-essential` with unrestricted installation (`sudo apt` and `pip install`).
- **Remote Access Options**:
  - **noVNC WebUI**: `http://localhost:8080`
  - **SSH Server**: `ssh -p 2222 antigravity@localhost`
- **Dedicated Project Mount**: Mount your local project code directory to `/projects` inside the container (accessible on the Desktop and in `/workspace/projects`).
- **Persistent Storage**: Mapped `./workspace` and `./projects` folders, plus a persistent Docker volume for `/home/antigravity` (preserving dotfiles, shell history, auth credentials, and configs).


---

## 🛠️ Quick Start

### 1. Build and Start the Container

```bash
docker compose up -d --build
```

### 2. Access the Desktop via Browser

Open your browser and navigate to:
```
http://localhost:8080
```
The session will automatically connect and resize to your browser window.

### 3. Connect via SSH (Optional)

You can also open an interactive shell directly via SSH:
```bash
ssh -p 2222 antigravity@localhost
```
- Default password: `antigravity` (configurable in `.env` / `docker-compose.yml`)

---

## 🧠 Using Antigravity

Inside the desktop or terminal:

1. **Desktop Shortcut**: Double-click the **Antigravity CLI** icon on the desktop.
2. **Terminal**: Run `agy` or `antigravity` from any shell:
   ```bash
   agy
   ```
3. **Authentication**:
   - On the first run, Antigravity will initiate authentication.
   - It will open Google Chrome inside the container desktop (or provide an authentication URL) to complete sign-in.

---

## 📦 Pulling Additional Languages & Packages

The `antigravity` user has full, passwordless `sudo` privileges.

### Python Packages
You can install Python packages directly:
```bash
pip install numpy pandas requests fastapi uvicorn
```
Or create dedicated virtual environments:
```bash
python3 -m venv /workspace/.venv
source /workspace/.venv/bin/activate
```

### System Packages
Install packages using `apt`:
```bash
sudo apt update
sudo apt install -y htop curl ripgrep fd-find neovim
```

### Node.js / NVM (Optional)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install --lts
```

---

## ⚙️ Configuration & Environment Variables

Edit `.env` or set environment variables in `docker-compose.yml`:

| Variable | Default | Description |
|---|---|---|
| `WEB_PORT` | `8080` | Host port for the noVNC WebUI |
| `SSH_PORT` | `2222` | Host port for the SSH server |
| `VNC_PORT` | `5900` | Host port for direct VNC clients |
| `RESOLUTION` | `1920x1080x24` | Virtual display resolution (`WIDTHxHEIGHTxDEPTH`) |
| `USER_PASSWORD` | `antigravity` | Password for user `antigravity` (SSH & `sudo`) |
| `VNC_PASSWORD` | *(empty)* | Optional password protection for noVNC/VNC |
| `PROJECT_DATA_PATH` | `./projects` | Host path to mount to `/projects` inside the container |
| `AUTORUN_ANTIGRAVITY_REMOTE` | `true` | Automatically run `agy remote-control serve` daemon on container startup |

| `AUTORUN_DESKTOP_TERMINAL` | `true` | Automatically open an interactive Antigravity terminal inside the desktop GUI |
| `ANTIGRAVITY_INSTANCE_NAME` | `antigravity-docker` | Name/ID registered for this instance in remote dashboard |
| `EXTRA_AGY_ARGS` | *(empty)* | Additional flags for `agy remote-control serve` (e.g. `--dangerously-skip-permissions`) |


---

## 💡 About Selkies vs. noVNC

- **noVNC** was selected here because it is lightweight, requires no dedicated GPU or WebRTC TURN/STUN infrastructure, and connects reliably across all browsers with responsive remote scaling.
- If high-framerate 60 FPS video or 3D GPU pass-through is needed later, the supervisor setup can be swapped with Selkies-GStreamer.

---

## 🛑 Stopping and Restarting

- **Stop container**:
  ```bash
  docker compose down
  ```
- **View logs**:
  ```bash
  docker compose logs -f
  ```
- **Reset persistent home directory**:
  ```bash
  docker compose down -v
  ```
