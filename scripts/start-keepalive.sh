#!/bin/bash
# Start the keepalive process in the background.
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SCRIPT="$SCRIPT_DIR/keepalive.sh"
PID_FILE="${KEEPALIVE_PID_FILE:-/var/run/keepalive.pid}"

if [ ! -x "$SCRIPT" ]; then
  chmod +x "$SCRIPT"
fi

if [ -f "$PID_FILE" ]; then
  PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    echo "keepalive already running: PID $PID"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

nohup "$SCRIPT" >/dev/null 2>&1 &
PID=$!
echo "$PID" > "$PID_FILE"
echo "keepalive started: PID $PID"
