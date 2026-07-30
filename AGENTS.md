# Agent Workspace Guide

Primary instruction source: `.github/copilot-instructions.md` (canonical when it conflicts with this file).

## Repo shape

- This repo builds cpuminer-opt from source via `git clone` in the Dockerfile; it does not use prebuilt tarballs.
- `Dockerfile` is the single image variant (no multi-stage variants).
- Default `docker run` uses `CMD ["cpuminer", "--config=config.json"]` directly — no entrypoint script.
- The image runs as non-root `cpuminer` by default.

## Verification

- Primary checks are Docker-based:
  - `docker build . -t cniweb/cpuminer-opt:test`
  - `docker run --rm cniweb/cpuminer-opt:test cpuminer --version`
  - `docker run --rm cniweb/cpuminer-opt:test cpuminer --cputest`
- `./build.sh build-only` is the same build path CI uses on `main`; it exits before registry login or pushes.
- `./security-check.sh` defaults to image `cniweb/cpuminer-opt:test`; build that tag first or pass a different image name.

## Shell and runtime constraints

- Build scripts (`build.sh`, `security-check.sh`) are `bash` scripts with `set -eu`; keep them POSIX-compatible where possible.
- Port `8080` is the expected HTTP/API port across Dockerfile, docs, and checks.
- The image runs as non-root `cpuminer` (uid=1000) by default.

## Release/versioning

- cpuminer-opt uses two-component versioning (e.g. `25.6` — no patch number).
- Version bumps must stay synchronized across all four files: `Dockerfile`, `build.sh`, `README.md`, and `CHANGELOG.md`.
- The release workflow (`.github/workflows/release-from-version.yml`) handles all four automatically: it updates version refs, and promotes `CHANGELOG.md`'s `## [Unreleased]` heading to `## [<version>] - <date>`. **The workflow fails fast if `CHANGELOG.md` has no `## [Unreleased]` section** — add one with the release notes before triggering it.
- Prefer that workflow for releases: it updates version refs, commits, tags `vX.Y`, and creates the GitHub release.
- The `Dockerfile` uses `ARG VERSION_TAG=v$version` (with `v` prefix), while `build.sh` uses `version="25.6"` (without `v` prefix).

## Small gotchas

- Since cpuminer-opt is built from source via git clone, the Docker build takes 60-90 seconds.
- `.dockerignore` excludes `.github`, `build.sh`, and `security-check.sh` from the build context.
- No `docker-entrypoint.sh` exists — the container uses `CMD` directly.

## CI

- `.github/workflows/docker-image.yml` runs on push and PR to `main`:
  - `validate` job: builds with `./build.sh build-only`, then runs `cpuminer --version`, `cpuminer --cputest`, and `security-check.sh` against it. Never pushes.
  - `docker` job (push events only, gated on `validate` passing): rebuilds, re-runs validation against the exact image about to ship, then tags and pushes versioned + `latest` + commit-SHA tags to Docker Hub and GHCR, and generates a SLSA provenance attestation and SBOM.
  - Removed Quay.io references from CI and build defaults (unused registry).
- Snyk container scanning runs on push/PR to `main` and weekly via `snyk-container-analysis.yml`.
- Dependabot monitors Docker base images and GitHub Actions versions.
