#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-devops-nginx:local-001}"
EXPECTED_BUILD_ID="${EXPECTED_BUILD_ID:-local-001}"
CONTAINER_NAME="devops-nginx-smoke-$$"
HOST_PORT="${HOST_PORT:-18080}"
HTML_FILE="$(mktemp)"
cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  rm -f "$HTML_FILE"
}
trap cleanup EXIT

if ! [[ "$HOST_PORT" =~ ^[0-9]+$ ]] || (( HOST_PORT < 1 || HOST_PORT > 65535 )); then
  echo "HOST_PORT must be a valid TCP port (1-65535)." >&2
  exit 2
fi

docker run -d --name "$CONTAINER_NAME" -p "127.0.0.1:${HOST_PORT}:80" "$IMAGE_NAME" >/dev/null
ready=false
for attempt in $(seq 1 30); do
  if curl --silent --show-error --fail "http://127.0.0.1:${HOST_PORT}/" -o "$HTML_FILE" 2>/dev/null; then
    ready=true
    break
  fi
  sleep 1
done
if [[ "$ready" != true ]]; then
  echo "NGINX did not return HTTP 2xx on port ${HOST_PORT}. Container logs:" >&2
  docker logs "$CONTAINER_NAME" >&2 || true
  exit 1
fi

grep -Fq 'Aditi Jadhav' "$HTML_FILE" || { echo 'FAIL: candidate name not found' >&2; exit 1; }
grep -Fq '20 October 2026' "$HTML_FILE" || { echo 'FAIL: assessment date not found' >&2; exit 1; }
grep -Fq "$EXPECTED_BUILD_ID" "$HTML_FILE" || { echo "FAIL: build ID '$EXPECTED_BUILD_ID' not found" >&2; exit 1; }
if grep -Fq '__BUILD_ID__' "$HTML_FILE"; then
  echo 'FAIL: unexpanded build ID placeholder found' >&2
  exit 1
fi
printf 'PASS: HTTP response and name/date/build ID verified at http://127.0.0.1:%s/
' "$HOST_PORT"
