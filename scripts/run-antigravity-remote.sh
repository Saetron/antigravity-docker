#!/usr/bin/env bash
set -euo pipefail

if [ "${AUTORUN_ANTIGRAVITY_REMOTE:-true}" != "true" ]; then
    echo "[*] AUTORUN_ANTIGRAVITY_REMOTE is set to false. Skipping background remote daemon."
    # Sleep indefinitely so supervisor doesn't spam restarts
    exec sleep infinity
fi

INSTANCE_NAME="${ANTIGRAVITY_INSTANCE_NAME:-antigravity-docker}"
export PATH="/usr/local/bin:$PATH"
export DISPLAY="${DISPLAY:-:1}"
export HOME="/home/antigravity"
export USER="antigravity"

# Wait for X11 display socket to become available (up to 15 seconds)
for _ in {1..30}; do
    [ -S /tmp/.X11-unix/X1 ] && break
    sleep 0.5
done

echo "[*] Starting Antigravity CLI Remote Control daemon (instance: $INSTANCE_NAME)..."

if ! command -v agy >/dev/null 2>&1; then
    echo "[!] agy binary not found, waiting for installer..."
    sleep 5
fi

# Build command arguments safely
AGY_CMD=(agy remote-control serve --name "$INSTANCE_NAME")
if [ -n "${EXTRA_AGY_ARGS:-}" ]; then
    read -r -a extra_args <<< "$EXTRA_AGY_ARGS"
    AGY_CMD+=("${extra_args[@]}")
fi

# Run agy remote-control serve. If it exits (e.g. pending first-time auth), wait before retry.
while true; do
    echo "[*] Executing: ${AGY_CMD[*]}"
    exit_code=0
    "${AGY_CMD[@]}" || exit_code=$?
    echo "[!] agy remote-control serve exited (exit code: $exit_code)."
    echo "[!] If this is your first run, complete authentication in the noVNC desktop terminal."
    sleep 10
done

