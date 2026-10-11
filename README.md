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
- **NVIDIA GPU Acceleration**: Hardware acceleration and CUDA support for machine learning, PyTorch, and graphics rendering using NVIDIA Container Toolkit.
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
| `NVIDIA_VISIBLE_DEVICES` | `all` | GPU devices to expose to the container (e.g. `all`, `0`, `0,1`) |
| `NVIDIA_DRIVER_CAPABILITIES` | `all` | Driver capabilities to mount (`compute,utility,graphics,video,display`) |


---

## 🎮 NVIDIA GPU Acceleration

This container includes OpenGL libraries (`mesa-utils`, `libgl1`, `libegl1`) and NVIDIA Container Toolkit hooks to enable GPU acceleration, CUDA computing, and graphics rendering.

### Prerequisites (Host Machine)
1. **NVIDIA Driver** installed on the host system.
2. **NVIDIA Container Toolkit** installed and configured for Docker:
   ```bash
   # On Ubuntu/Debian host:
   sudo apt-get install -y nvidia-container-toolkit
   sudo nvidia-ctk runtime configure --runtime=docker
   sudo systemctl restart docker
   ```

### Launching with GPU Support

#### Option A: Using the GPU compose override file (Recommended)
```bash
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d --build
```

#### Option B: Always enable GPU for `docker compose up`
Create a persistent `docker-compose.override.yml`:
```bash
cp docker-compose.gpu.yml docker-compose.override.yml
docker compose up -d
```

#### Option C: Using standard `docker run`
```bash
docker run -d \
  --name antigravity-remote \
  --gpus all \
  --shm-size 2gb \
  -p 8080:8080 \
  -p 2222:22 \
  -v $(pwd)/workspace:/workspace \
  -v $(pwd)/projects:/projects \
  antigravity-remote:latest
```

### Verifying GPU Inside the Container

Open a terminal inside the container (via noVNC browser or SSH) and run:

1. **Check NVIDIA driver and GPU visibility**:
   ```bash
   nvidia-smi
   ```
2. **Verify OpenGL Hardware Acceleration**:
   ```bash
   glxinfo | grep -i "OpenGL renderer"
   ```
3. **Test with PyTorch / CUDA (Python)**:
   ```bash
   pip install torch
   python3 -c "import torch; print('CUDA Available:', torch.cuda.is_available()); print('Device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None')"
   ```

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

