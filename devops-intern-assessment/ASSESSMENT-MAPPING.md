# Assessment Requirement Mapping

| Assessment requirement | Implementation file(s) | How to verify |
|---|---|---|
| Use a simple NGINX application | `index.html`, `Dockerfile` | Build and open the page |
| Display candidate name | `index.html` | Check rendered webpage |
| Display assessment date | `index.html` | Check rendered webpage |
| Inject build ID at image build time | `Dockerfile`, `scripts/build.sh` | Build with `BUILD_ID=demo-123`, then run smoke test |
| Include `.gitignore` and exclude IDE metadata | `.gitignore`, `.dockerignore` | Review `git status --short`; confirm `.idea/` is ignored |
| Build a container image | `Dockerfile`, `scripts/build.sh` | `./scripts/build.sh` |
| Automate CI on pushes and pull requests | `.github/workflows/ci.yml` | Inspect GitHub Actions run |
| Test the built website | `scripts/test.sh`, `.github/workflows/ci.yml` | Confirm HTTP and page-content checks pass |
| Publish an immutable commit-specific image | `.github/workflows/ci.yml` | Confirm GHCR has a `sha-<commit>` tag |
| Replace Kubernetes with Nomad | `nomad/nginx.nomad.hcl` | `nomad job validate ...` and `nomad job status nginx-web` |
| Use Docker task driver and HTTP health check | `nomad/nginx.nomad.hcl` | Inspect healthy allocation and service check |
| Aggregate container logs | `logging/docker-compose.yml`, `logging/config.alloy`, `logging/loki-config.yaml` | Generate a request and query Loki |
| Document reproducible steps | `README.md`, `GIT-UPLOAD-GUIDE.md` | Follow steps on a clean machine |
| Explain which tests actually passed | `VALIDATION-REPORT.md` | Compare report with real run evidence |

## Important distinction

Static checks can verify that files exist and some configuration expectations are present. They cannot prove that Docker built an image, GitHub published it, Nomad ran an allocation, or Loki ingested logs. Those runtime requirements need real environment evidence.
