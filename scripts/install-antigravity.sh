#!/usr/bin/env bash
set -euo pipefail

echo "[*] Installing Google Antigravity CLI..."

# Install dependencies if missing
if ! command -v curl >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends curl ca-certificates
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi

# Run official installer to target /usr/local/bin
if curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- -d /usr/local/bin; then
    echo "[✓] Antigravity CLI installed successfully."
else
    echo "[!] Warning: Direct install failed (possibly network issue during build). Will retry at runtime."
fi

# Ensure alias/symlink exists if binary is present
if [ -f "/usr/local/bin/agy" ]; then
    chmod +x /usr/local/bin/agy
    ln -sf /usr/local/bin/agy /usr/local/bin/antigravity
fi

