# Nile Market Storefront — Enterprise CI/CD Pipeline
![CI/CD Release Pipeline](https://github.com/gasoom/nile-storefront/actions/work
flows/storefront-ci.yml/badge.svg)
Production-grade containerized web service built with **non-root Nginx (UID 101)
**, verified by **Hadolint** and automated **Smoke Testing**, and published via
**Docker Buildx** to Docker Hub.
- **Engineer:** Eng. Abualgasim Hazim
- **Module:** DEV-OPS-WEEK-07 Capstone Project
## Quick Start (Pull & Run from Docker Hub)
```bash
docker pull gasoom/nile-storefront:1.0.0
docker run -d --name storefront-prod -p 8080:8080 gasoom/nile-storefront:1.0.0
curl http://localhost:8080/healthz
curl http://localhost:8080/
```