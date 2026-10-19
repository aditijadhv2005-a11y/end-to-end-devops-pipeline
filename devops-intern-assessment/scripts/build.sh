#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-devops-nginx}"
if [[ -n "${BUILD_ID:-}" ]]; then
  build_id="$BUILD_ID"
elif git rev-parse --verify HEAD >/dev/null 2>&1; then
  build_id="$(git rev-parse --short=12 HEAD)"
else
  build_id="local-$(date -u +%Y%m%dT%H%M%SZ)"
fi

if [[ ! "$build_id" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  echo "BUILD_ID must contain only letters, digits, dots, underscores, or hyphens." >&2
  exit 2
fi

image_ref="${IMAGE_NAME}:${build_id}"
echo "Building ${image_ref} (BUILD_ID=${build_id})"
docker build --build-arg "BUILD_ID=${build_id}" \
  --label "org.opencontainers.image.revision=${build_id}" \
  --tag "$image_ref" .
echo "Built image: ${image_ref}"
echo "Test with: IMAGE_NAME='${image_ref}' EXPECTED_BUILD_ID='${build_id}' ./scripts/test.sh"
