# Validation Report

## Checks passed in this environment

- `scripts/validate-static.py`: static consistency checks passed.
- Bash syntax checks passed for `scripts/build.sh`, `scripts/test.sh`, and `scripts/deploy.sh`.
- YAML syntax parsing passed for the GitHub Actions workflow, Compose file, and Loki configuration using PyYAML.
- Build-ID placeholder substitution simulation passed.
- Native NGINX runtime test passed: the installed local NGINX served the rendered page over HTTP 200; the response contained `Aditi Jadhav`, `20 October 2026`, and the substituted identifier `native-nginx-test-001`; the native NGINX access log recorded the test request.

The native NGINX test validates the HTML/webserver content path only. It is not a Docker container test.

## Not executed here

Docker CLI/daemon, Nomad CLI/cluster, GHCR publishing, and the Loki + Alloy runtime are unavailable in this environment. The following remain **not verified** and must not be claimed as passed until tested in the target environment:

- Actual Docker image build and container smoke test.
- GitHub Actions run and GHCR image publication.
- Nomad job submission, healthy allocation, and HTTP endpoint from the Nomad client.
- Real NGINX Docker JSON logs arriving in Loki and being returned by a Loki query.

## Commands to complete runtime verification

```bash
# Local Docker build + smoke test
BUILD_ID=local-001 IMAGE_NAME=devops-nginx ./scripts/build.sh
IMAGE_NAME=devops-nginx:local-001 EXPECTED_BUILD_ID=local-001 ./scripts/test.sh

# On a configured Nomad cluster, after a successful GHCR publish
export IMAGE="ghcr.io/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY:sha-FULL_COMMIT_SHA"
nomad job validate -var "image=${IMAGE}" nomad/nginx.nomad.hcl
nomad job plan -var "image=${IMAGE}" nomad/nginx.nomad.hcl
nomad job run -var "image=${IMAGE}" nomad/nginx.nomad.hcl
nomad job status nginx-web
curl -fsS http://NOMAD_CLIENT_ADDRESS:8080/

# On the same Linux Docker host as the Nomad client
cd logging
docker compose config
docker compose up -d
curl -fsS http://127.0.0.1:3100/ready
curl -G -sS 'http://127.0.0.1:3100/loki/api/v1/query_range' \\
  --data-urlencode 'query={job="docker"}' --data-urlencode 'limit=50'
```
