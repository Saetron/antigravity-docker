# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

ARG VERSION=1.1.0

LABEL maintainer="Antigravity Container" \
      description="Lightweight Linux desktop with Google Chrome, Antigravity CLI, GitHub CLI, Python, and noVNC WebUI" \
      org.opencontainers.image.title="Antigravity Remote Desktop Container" \
      org.opencontainers.image.description="Lightweight Linux desktop with Google Chrome, Antigravity CLI, GitHub CLI, Python, and noVNC WebUI" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.licenses="EUPL-1.2"

# Prevent interactive prompts during apt install
ENV CONTAINER_VERSION=${VERSION} \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DISPLAY=:1 \
    RESOLUTION=1920x1080x24 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all


# 1. Install base utilities, X11, XFCE desktop, noVNC, and OpenSSH
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    zsh \
    curl \
    wget \
    gnupg \
    ca-certificates \
    locales \
    sudo \
    procps \
    htop \
    tmux \
    nano \
    vim \
    jq \
    unzip \
    supervisor \
    openssh-server \
    # X11 & Desktop Environment
    xvfb \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    adwaita-icon-theme \
    fonts-dejavu-core \
    fonts-noto-color-emoji \
    libnotify4 \
    # Hardware Acceleration & OpenGL (GPU)
    mesa-utils \
    libgl1-mesa-dri \
    libgl1 \
    libegl1 \
    pciutils \
    # Web VNC
    novnc \
    websockify \
    # Git
    git \
    git-lfs \
    # Python Development Environment
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install GitHub CLI (gh)
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Create non-root developer user with sudo privileges & configure global pip
RUN groupadd -g 1000 antigravity \
    && useradd -u 1000 -g antigravity -m -s /bin/bash antigravity \
    && echo "antigravity ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/antigravity \
    && chmod 0440 /etc/sudoers.d/antigravity \
    && printf "[global]\nbreak-system-packages = true\n" > /etc/pip.conf \
    && mkdir -p /workspace /projects \
    && chown -R antigravity:antigravity /workspace /projects

# 4. Copy and run build-time installers first to maximize Docker layer cache reuse
COPY --chmod=0755 scripts/install-chrome.sh scripts/install-antigravity.sh /opt/scripts/
RUN /opt/scripts/install-chrome.sh \
    && (/opt/scripts/install-antigravity.sh || true)

# 5. Copy runtime scripts, supervisor configs, and desktop entries
COPY --chmod=0755 scripts/entrypoint.sh scripts/run-antigravity-remote.sh /opt/scripts/
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/ /opt/assets/

# WebUI (noVNC), VNC RFB, and SSH ports
EXPOSE 8080 5900 22

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -fs http://localhost:8080/ >/dev/null || exit 1

WORKDIR /workspace

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]

