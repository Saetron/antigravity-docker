#!/usr/bin/env bash
set -e

# Configuration defaults
RESOLUTION="${RESOLUTION:-1920x1080x24}"
USER_PASSWORD="${USER_PASSWORD:-antigravity}"
VNC_PASSWORD="${VNC_PASSWORD:-}"

echo "=========================================="
echo " Starting Antigravity Development Desktop "
echo "=========================================="
echo "Display Resolution: $RESOLUTION"

# Set non-root user password for sudo / ssh
echo "antigravity:${USER_PASSWORD}" | chpasswd

# Setup VNC Authentication
mkdir -p /home/antigravity/.vnc
if [ -n "$VNC_PASSWORD" ]; then
    echo "[*] Setting custom VNC password..."
    x11vnc -storepasswd "$VNC_PASSWORD" /home/antigravity/.vnc/passwd
    chmod 600 /home/antigravity/.vnc/passwd
    export X11VNC_AUTH="-rfbauth /home/antigravity/.vnc/passwd"
else
    echo "[*] No VNC password set (passwordless web access)."
    export X11VNC_AUTH="-nopw"
fi
chown -R antigravity:antigravity /home/antigravity/.vnc

# Setup SSH Server Host Keys
mkdir -p /var/run/sshd
ssh-keygen -A >/dev/null 2>&1 || true

# Prepare Desktop environment & shortcuts
mkdir -p /home/antigravity/Desktop /home/antigravity/.config/xfce4 /home/antigravity/.config/autostart
if [ -d "/opt/assets" ]; then
    cp -f /opt/assets/*.desktop /home/antigravity/Desktop/ 2>/dev/null || true
    chmod +x /home/antigravity/Desktop/*.desktop 2>/dev/null || true

    # Autostart interactive Antigravity terminal inside desktop UI if enabled
    if [ "${AUTORUN_DESKTOP_TERMINAL:-true}" = "true" ]; then
        echo "[*] Configuring Antigravity autostart in desktop session..."
        cp -f /opt/assets/antigravity.desktop /home/antigravity/.config/autostart/antigravity.desktop
        chmod +x /home/antigravity/.config/autostart/antigravity.desktop
    fi
fi

# Ensure workspace, project mount, and home ownership
mkdir -p /workspace /projects
chown -R antigravity:antigravity /home/antigravity /workspace /projects 2>/dev/null || true

# Provide accessible project links
ln -sfn /projects /workspace/projects
ln -sfn /projects /home/antigravity/Desktop/projects
ln -sfn /projects /home/antigravity/projects



# Configure noVNC default redirect page
if [ -d "/usr/share/novnc" ]; then
    cat <<HTML > /usr/share/novnc/index.html
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=remote" />
    <title>Connecting to Antigravity Remote...</title>
</head>
<body style="background:#1e1e1e;color:#fff;font-family:sans-serif;text-align:center;padding-top:20vh;">
    <h2>Connecting to Antigravity Remote Desktop...</h2>
    <p>If not redirected automatically, <a href="vnc.html?autoconnect=true&resize=remote" style="color:#4dabf7;">click here</a>.</p>
</body>
</html>
HTML
fi

# Runtime check for Antigravity CLI (installs if missing or updated)
if [ ! -f "/usr/local/bin/agy" ]; then
    echo "[*] Antigravity CLI binary not detected, running installer..."
    /opt/scripts/install-antigravity.sh || true
fi

# Export variables for supervisord
export ENV_RESOLUTION="$RESOLUTION"
export ENV_X11VNC_AUTH="$X11VNC_AUTH"

echo "[✓] Environment ready. Starting services..."
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
