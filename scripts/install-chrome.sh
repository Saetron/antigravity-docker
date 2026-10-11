#!/usr/bin/env bash
set -euo pipefail

ARCH="$(dpkg --print-architecture)"
echo "[*] Detecting architecture for Chrome installation: $ARCH"

if [ "$ARCH" = "amd64" ]; then
    echo "[*] Installing official Google Chrome (amd64)..."
    apt-get update
    apt-get install -y --no-install-recommends wget gnupg ca-certificates
    wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt-get install -y --no-install-recommends /tmp/google-chrome.deb || apt-get install -fy --no-install-recommends
    rm -f /tmp/google-chrome.deb
    CHROME_TARGET="/usr/bin/google-chrome-stable"
else
    echo "[*] Native Google Chrome deb is amd64-only. Installing native Chromium for $ARCH..."
    apt-get update
    apt-get install -y --no-install-recommends chromium
    CHROME_TARGET="$(which chromium)"
fi

# Create sandbox-safe wrappers in /usr/local/bin
cat <<WRAPPER > /usr/local/bin/google-chrome
#!/usr/bin/env bash
exec "$CHROME_TARGET" --no-sandbox --disable-dev-shm-usage --disable-gpu-sandbox "\$@"
WRAPPER

chmod +x /usr/local/bin/google-chrome
ln -sf /usr/local/bin/google-chrome /usr/local/bin/google-chrome-stable
ln -sf /usr/local/bin/google-chrome /usr/local/bin/chrome
ln -sf /usr/local/bin/google-chrome /usr/local/bin/chromium-browser

echo "[✓] Chrome / Chromium installed and configured successfully."
