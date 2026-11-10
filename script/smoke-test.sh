#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-nile-storefront:abc}"
EXPECTED_VERSION="${EXPECTED_VERSION:-abc}"
CONTAINER_NAME="nile-storefront-smoke"
HOST_PORT="18080"

cleanup() {
  echo "--- container log ---"
  docker logs "${CONTAINER_NAME}" 2>&1 || true
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
docker run -d --name "${CONTAINER_NAME}" -p "${HOST_PORT}:8080" "${IMAGE_NAME}" >/dev/null

echo "waiting for container to become healthy..."
for attempt in $(seq 1 40); do
  status=$(docker inspect --format='{{.State.Health.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "starting")
  if [ "${status}" = "healthy" ]; then
    echo "container is healthy"
    break
  fi
  if [ "${status}" = "unhealthy" ]; then
    echo "container is unhealthy"
    exit 1
  fi
  sleep 2
done

[ "$(docker inspect --format='{{.State.Health.Status}}' "${CONTAINER_NAME}")" = "healthy" ]
[ "$(docker exec "${CONTAINER_NAME}" id -u)" = "101" ]
[ "$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${HOST_PORT}/health")" = "200" ]
[ "$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${HOST_PORT}/")" = "200" ]
[ "$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${HOST_PORT}/does-not-exist")" = "404" ]

curl -fsS "http://localhost:${HOST_PORT}/" | grep -F "Nile Market Storefront"
curl -fsS "http://localhost:${HOST_PORT}/" | grep -F "${EXPECTED_VERSION}"

echo "Smoke test passed"