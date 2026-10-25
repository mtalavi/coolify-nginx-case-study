#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Copyright 2026 mtalavi
set -eu
image=${1:-coolify-nginx-refresh:4.5.0}
name="coolify-nginx-check-$$"
cleanup() { docker rm -f "$name" >/dev/null 2>&1 || true; }
trap cleanup EXIT
trap 'exit 130' INT TERM

docker run -d --pull=never --name "$name" --network none \
  --memory 512m --cpus 0.5 --pids-limit 256 \
  -e AUTORUN_ENABLED=false -e CACHE_STORE=array -e SESSION_DRIVER=array \
  "$image" >/dev/null

ready=false
for attempt in $(seq 1 45); do
  status=$(docker exec "$name" curl -sS --max-time 2 -o /dev/null \
    -w '%{http_code}' http://127.0.0.1:8080/build/manifest.json 2>/dev/null || true)
  if [ "$status" = 200 ]; then ready=true; break; fi
  sleep 1
done
if [ "$ready" != true ]; then
  docker logs --tail 60 "$name"
  printf '%s\n' 'FAIL: isolated static HTTP check'
  exit 1
fi
docker exec "$name" nginx -t
docker exec "$name" nginx -v 2>&1 | grep -F 'nginx/1.31.8'
printf '%s\n' 'PASS: Nginx syntax and isolated static HTTP 200 (not full application acceptance)'

