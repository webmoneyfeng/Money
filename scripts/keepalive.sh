#!/bin/bash
# Keepalive script: request the subscription endpoint at a random interval.
set -u

URL="${KEEPALIVE_URL:-https://qw.danao.eu.org/sub}"
MIN_INTERVAL="${KEEPALIVE_MIN_INTERVAL:-7200}"   # 2 hours
MAX_INTERVAL="${KEEPALIVE_MAX_INTERVAL:-14400}"  # 4 hours
LOG="${KEEPALIVE_LOG:-/var/log/keepalive.log}"

mkdir -p "$(dirname "$LOG")"
echo "$(date -u +"%Y-%m-%d %H:%M:%S UTC") - 保活脚本启动（随机间隔 2-4 小时）" >> "$LOG"

random_interval() {
  local range=$((MAX_INTERVAL - MIN_INTERVAL + 1))
  echo $((MIN_INTERVAL + RANDOM % range))
}

while true; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}"     "$URL"     --connect-timeout 10     --max-time 15)

  TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC") 

  if [ "$HTTP_CODE" = "200" ]; then
    echo "$TIMESTAMP - 保活成功: HTTP $HTTP_CODE" >> "$LOG"
  else
    echo "$TIMESTAMP - 保活失败: HTTP $HTTP_CODE" >> "$LOG"
  fi

  INTERVAL=$(random_interval)
  echo "$TIMESTAMP - 下次访问等待: $INTERVAL 秒" >> "$LOG"
  sleep "$INTERVAL"
done
