#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
podman run \
  --rm \
  --workdir /srv \
  -p 3003:3003 \
  -v "$SCRIPT_DIR:/srv:ro" \
  --name cloud-init \
  docker.io/library/python:3-alpine python3 -m http.server 3003
