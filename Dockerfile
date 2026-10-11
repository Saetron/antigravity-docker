# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

LABEL maintainer="Antigravity Container"
LABEL description="Lightweight Linux desktop with Google Chrome, Antigravity CLI, GitHub CLI, Python, and noVNC WebUI"

# Prevent interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV DISPLAY=:1
ENV RESOLUTION=1920x1080x24
ENV PIP_BREAK_SYSTEM_PACKAGES=1

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

# 3. Create non-root developer user with sudo privileges
RUN groupadd -g 1000 antigravity \
    && useradd -u 1000 -g antigravity -m -s /bin/bash antigravity \
    && echo "antigravity ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/antigravity \
    && chmod 0440 /etc/sudoers.d/antigravity

# Configure global pip behavior
RUN mkdir -p /etc && cat <<EOF > /etc/pip.conf
[global]
break-system-packages = true
EOF

# Copy helper scripts, supervisor configs, and desktop entries
COPY scripts/ /opt/scripts/
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY assets/ /opt/assets/

RUN chmod +x /opt/scripts/*.sh

# 4. Install Google Chrome / Chromium
RUN /opt/scripts/install-chrome.sh

# 5. Install Google Antigravity CLI
RUN /opt/scripts/install-antigravity.sh || true

# Prepare default workspace and projects directories
RUN mkdir -p /workspace /projects && chown -R antigravity:antigravity /workspace /projects

# WebUI (noVNC), VNC RFB, and SSH ports
EXPOSE 8080 5900 22

WORKDIR /workspace


ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
