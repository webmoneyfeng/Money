#!/bin/bash
# Keepalive script: periodically requests the subscription endpoint to reduce AutoSleep risk.
set -u

URL="${KEEPALIVE_URL:-https://qw.danao.eu.org/sub}"
INTERVAL="${KEEPALIVE_INTERVAL:-1200}" # 20 minutes
LOG="${KEEPALIVE_LOG:-/var/log/keepalive.log}"

mkdir -p "$(dirname "$LOG")"
echo "$(date -u +"%Y-%m-%d %H:%M:%S UTC") - 保活脚本启动" >> "$LOG"

while true; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}"     "$URL"     --connect-timeout 10     --max-time 15)

  TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC") 

  if [ "$HTTP_CODE" = "200" ]; then
    echo "$TIMESTAMP - 保活成功: HTTP $HTTP_CODE" >> "$LOG"
  else
    echo "$TIMESTAMP - 保活失败: HTTP $HTTP_CODE" >> "$LOG"
  fi

  sleep "$INTERVAL"
done
