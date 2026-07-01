#!/usr/bin/env bash

set -euo pipefail

REGISTRY="${DOCKER_REGISTRY:-XXXXXX}"
IMAGE_REPO="${1:-a-share-heatmap}"
IMAGE_TAG="${2:-latest}"
FULL_IMAGE="${REGISTRY}/${IMAGE_REPO}:${IMAGE_TAG}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Project root: ${PROJECT_ROOT}"
echo "Target image: ${FULL_IMAGE}"
echo "Usage: ./scripts/docker-push.sh [repo] [tag]"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed or not in PATH" >&2
  exit 1
fi

if [[ ! -f "${PROJECT_ROOT}/Dockerfile" ]]; then
  echo "Dockerfile not found in ${PROJECT_ROOT}" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "docker daemon is not running or not reachable" >&2
  exit 1
fi

if [[ "${IMAGE_REPO}" != */* ]]; then
  echo "Warning: image repo '${IMAGE_REPO}' has no namespace. If your registry requires one, use something like 'team/${IMAGE_REPO}'." >&2
fi

if ! grep -q "\"${REGISTRY}\"" "${HOME}/.docker/config.json" 2>/dev/null; then
  echo "docker login may be required for ${REGISTRY}. Run: docker login ${REGISTRY}" >&2
fi

echo "Building image..."
docker build \
  --tag "${FULL_IMAGE}" \
  "${PROJECT_ROOT}"

echo "Pushing image..."
docker push "${FULL_IMAGE}"

echo "Done."
echo "Image pushed: ${FULL_IMAGE}"
