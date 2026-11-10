#!/usr/bin/env bash
set -euo pipefail

: "${IMAGE:?IMAGE is required}"
: "${EXPECTED_VERSION:?EXPECTED_VERSION is required}"

HOST_PORT="${HOST_PORT:-8080}"
NAME="smoke-$$"
BASE="http://127.0.0.1:${HOST_PORT}"

cleanup() {
  echo "=== Container logs ==="
  docker logs "$NAME" || true
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== 1. Run container: $IMAGE ==="
docker run -d -p "127.0.0.1:${HOST_PORT}:8080" --name "$NAME" "$IMAGE" >/dev/null

echo "=== 2. Wait for healthy ==="
STATUS=""
for i in $(seq 1 20); do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$NAME")
  echo "Check #$i: [$STATUS]"
  [ "$STATUS" = "healthy" ] && break
  sleep 2
done
[ "$STATUS" = "healthy" ] || { echo "FAILED: container not healthy"; exit 1; }

echo "=== 3. Runtime user must not be root ==="
RUN_USER=$(docker exec "$NAME" id -u)
echo "Runtime UID: $RUN_USER"
[ "$RUN_USER" != "0" ] || { echo "FAILED: running as root"; exit 1; }

echo "=== 4. HTTP checks ==="
[ "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/healthz")" = "200" ] || { echo "FAILED: /healthz"; exit 1; }
[ "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/")" = "200" ] || { echo "FAILED: /"; exit 1; }
PAGE=$(curl -sSf "$BASE/")
echo "$PAGE" | grep -q "Nile Market Storefront" || { echo "FAILED: title missing"; exit 1; }
echo "$PAGE" | grep -q "$EXPECTED_VERSION" || { echo "FAILED: version not in page"; exit 1; }
[ "$(curl -s -o /dev/null -w '%{http_code}' "$BASE/does-not-exist")" = "404" ] || { echo "FAILED: expected 404"; exit 1; }

echo "ALL SMOKE TESTS PASSED for version $EXPECTED_VERSION"