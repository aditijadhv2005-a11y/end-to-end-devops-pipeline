#!/usr/bin/env python3
"""Offline consistency checks; these do not replace Docker/Nomad integration tests."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

def require(condition, message):
    if not condition:
        errors.append(message)

html = (ROOT / "index.html").read_text(encoding="utf-8")
dockerfile = (ROOT / "Dockerfile").read_text(encoding="utf-8")
nomad = (ROOT / "nomad/nginx.nomad.hcl").read_text(encoding="utf-8")
workflow = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
alloy = (ROOT / "logging/config.alloy").read_text(encoding="utf-8")

require("Aditi Jadhav" in html, "index.html is missing the candidate name")
require("20 October 2026" in html, "index.html is missing the assessment date")
require("__BUILD_ID__" in html, "index.html must contain the build ID placeholder")
require("ARG BUILD_ID" in dockerfile, "Dockerfile must declare ARG BUILD_ID")
require("sed -i" in dockerfile, "Dockerfile must inject BUILD_ID into the HTML")
require("nginx:1.28-alpine" in dockerfile, "Dockerfile must use the expected NGINX base image")
require('driver = "docker"' in nomad, "Nomad job must use the Docker driver")
require('static = 8080' in nomad and 'to     = 80' in nomad, "Nomad job must map host port 8080 to container port 80")
require("service {" in nomad and 'type     = "http"' in nomad, "Nomad job must include an HTTP health check")
require("GITHUB_SHA" in workflow and "docker push" in workflow, "CI must build using a Git SHA and publish the image")
require("loki.source.file" in alloy and "loki.write" in alloy and "stage.docker" in alloy, "Alloy must collect Docker JSON logs and forward them to Loki")
require((ROOT / ".gitignore").exists() and ".idea/" in (ROOT / ".gitignore").read_text(), ".gitignore must exclude .idea/")
require(not (ROOT / ".idea").exists(), ".idea/ must not be present in the project")

build_id = "static-check-20261020"
rendered = html.replace("__BUILD_ID__", build_id)
require("__BUILD_ID__" not in rendered, "Build ID placeholder substitution failed")
require(build_id in rendered, "Rendered HTML does not contain the substituted build ID")

try:
    import yaml
except ImportError:
    print("SKIP: YAML parsing (install PyYAML with: python3 -m pip install pyyaml)")
else:
    try:
        for file in [ROOT / ".github/workflows/ci.yml", ROOT / "logging/docker-compose.yml", ROOT / "logging/loki-config.yaml"]:
            # PyYAML's YAML 1.1 parser treats the key `on` as boolean, but syntax parsing is still useful.
            yaml.safe_load(file.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"YAML parse check failed: {exc}")
    else:
        print("PASS: YAML syntax parsing (GitHub Actions, Compose, Loki)")

if errors:
    print("STATIC VALIDATION FAILED:")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)
print("PASS: static project consistency checks")
print("PASS: build-time HTML placeholder substitution simulation")
print("NOTE: Docker image build, Nomad deployment, GHCR publishing, and Loki ingestion require a real target environment.")
