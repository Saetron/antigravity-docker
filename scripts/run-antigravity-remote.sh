#!/usr/bin/env bash
set -e

if [ "${AUTORUN_ANTIGRAVITY_REMOTE:-true}" != "true" ]; then
    echo "[*] AUTORUN_ANTIGRAVITY_REMOTE is set to false. Skipping background remote daemon."
    # Sleep indefinitely so supervisor doesn't spam restarts
    exec sleep infinity
fi

# Wait for X11 & desktop environment to stabilize
sleep 5

INSTANCE_NAME="${ANTIGRAVITY_INSTANCE_NAME:-antigravity-docker}"
export PATH="/usr/local/bin:$PATH"
export DISPLAY=":1"
export HOME="/home/antigravity"
export USER="antigravity"

echo "[*] Starting Antigravity CLI Remote Control daemon (instance: $INSTANCE_NAME)..."

if ! command -v agy >/dev/null 2>&1; then
    echo "[!] agy binary not found, waiting for installer..."
    sleep 5
fi

# Run agy remote-control serve. If it exits (e.g. pending first-time auth), wait before retry.
while true; do
    echo "[*] Executing: agy remote-control serve --name \"$INSTANCE_NAME\" ${EXTRA_AGY_ARGS:-}"
    agy remote-control serve --name "$INSTANCE_NAME" ${EXTRA_AGY_ARGS:-} || {
        echo "[!] agy remote-control serve exited (exit code: $?)."
        echo "[!] If this is your first run, complete authentication in the noVNC desktop terminal."
        sleep 10
    }
done
