# Changelog

All notable changes to the **Antigravity Remote Desktop Container** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.1.0] - 2026-10-21

### Added
- **Dependabot**: Added automated weekly configuration (`.github/dependabot.yml`) for GitHub Actions and Docker base image updates.
- **Project Changelog**: Added `CHANGELOG.md` adhering to Keep a Changelog and Semantic Versioning standards.
- **Agent Guidelines**: Updated `AGENTS.md` with explicit rules requiring AI agents to update `CHANGELOG.md` on every change.
- **Documentation**: Added License and Changelog links to `README.md`.

### Changed
- **CI/CD Workflow Actions**: Upgraded GitHub Actions in `.github/workflows/docker-build.yml` via Dependabot:
  - Bumped `actions/checkout` from `v4` to `v7` ([#6](https://github.com/Saetron/antigravity-docker/pull/6)).
  - Bumped `docker/setup-qemu-action` from `v3` to `v4` ([#5](https://github.com/Saetron/antigravity-docker/pull/5)).
  - Bumped `docker/setup-buildx-action` from `v3` to `v4` ([#4](https://github.com/Saetron/antigravity-docker/pull/4)).
  - Bumped `docker/login-action` from `v3` to `v4` ([#2](https://github.com/Saetron/antigravity-docker/pull/2)).
  - Bumped `docker/metadata-action` from `v5` to `v6` ([#3](https://github.com/Saetron/antigravity-docker/pull/3)).
  - Bumped `docker/build-push-action` from `v5` to `v7` ([#1](https://github.com/Saetron/antigravity-docker/pull/1)).
- **Dockerfile & Caching**: Optimized Dockerfile layer caching order, consolidated package installation steps, and refined ignore rules (`.dockerignore`).
- **Container Lifecycle Scripts**: Refactored and hardened container lifecycle scripts (`entrypoint.sh`, `install-chrome.sh`, `install-antigravity.sh`, and `run-antigravity-remote.sh`) with stricter error handling (`set -euo pipefail`) and permission validation.
- **Supervisor Configuration**: Optimized process priority and logging settings for background daemons.

### Fixed
- **Supervisord Environment Variable Expansion**: Fixed `ENV_X11VNC_AUTH` and `ENV_RESOLUTION` expansion error in `scripts/entrypoint.sh` where variables were exported with a redundant `ENV_` prefix (causing Supervisord to register them as `ENV_ENV_X11VNC_AUTH` and `ENV_ENV_RESOLUTION`).

---

## [1.0.0] - 2026-10-12

### Added
- **Base System**: Lightweight Debian 12 (Bookworm) Slim container with XFCE4 desktop environment.
- **Web & Remote Access**:
  - In-browser HTML5 desktop access via noVNC (`http://localhost:8080`) and websockify.
  - OpenSSH server running on container port 22 (mapped to host port 2222).
  - Direct VNC server access on port 5900 via `x11vnc`.
- **Google Antigravity CLI (`agy`)**: Official CLI pre-installed with background remote daemon mode (`agy remote-control serve`) and desktop launcher.
- **Google Chrome / Chromium**: Pre-installed browser with container sandbox compatibility wrappers (`--no-sandbox`, `--disable-dev-shm-usage`).
- **Development Tooling**:
  - Python 3 (`python3`, `pip`, `venv`, `build-essential`).
  - GitHub CLI (`gh`), Git, and Git LFS.
- **NVIDIA GPU Acceleration**: Hardware acceleration and CUDA pass-through support via `docker-compose.gpu.yml`.
- **Persistence & Mounts**: Mapped project workspace mounts (`/workspace` and `/projects`) and persistent `/home/antigravity` named volume.
- **CI/CD Workflow**: GitHub Actions workflow (`.github/workflows/docker-publish.yml`) for automated builds and manual publishing to GitHub Container Registry (GHCR).
- **Licensing**: European Union Public Licence (EUPL-1.2).
- **Agent Guidelines**: `AGENTS.md` providing architectural context and operations reference for AI agents.
