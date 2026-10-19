#!/usr/bin/env bash
set -euo pipefail

JOB_FILE="${JOB_FILE:-nomad/nginx.nomad.hcl}"
IMAGE="${IMAGE:-}"
FORCE_PULL="${FORCE_PULL:-true}"
if [[ -z "$IMAGE" ]]; then
  echo "Set IMAGE, e.g. IMAGE=ghcr.io/OWNER/REPO:sha-COMMIT ./scripts/deploy.sh" >&2
  exit 2
fi
if [[ "$FORCE_PULL" != true && "$FORCE_PULL" != false ]]; then
  echo "FORCE_PULL must be true or false." >&2
  exit 2
fi

nomad job validate -var "image=${IMAGE}" -var "force_pull=${FORCE_PULL}" "$JOB_FILE"
nomad job plan -var "image=${IMAGE}" -var "force_pull=${FORCE_PULL}" "$JOB_FILE"
read -r -p "Submit this Nomad deployment? Type yes to continue: " answer
if [[ "$answer" != yes ]]; then
  echo "Deployment cancelled."
  exit 0
fi
nomad job run -var "image=${IMAGE}" -var "force_pull=${FORCE_PULL}" "$JOB_FILE"
echo "Deployment submitted. Check with: nomad job status nginx-web"
