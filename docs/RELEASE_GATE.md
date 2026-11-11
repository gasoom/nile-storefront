# Nile Market Storefront - Release Gate

No image is published to Docker Hub unless it passes:
1. Hadolint on Dockerfile (zero warnings)
2. Container runs as non-root (UID 101)
3. /healthz returns 200 "ok" and the container reports healthy
4. / returns 200, unknown paths return 404, and the page shows the build version

Versioning:
- Every push to main publishes sha-<short> and latest.
- Tag v1.0.0 publishes 1.0.0 and 1.0.
