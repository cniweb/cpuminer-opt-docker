# Agent Workspace Guide

Primary instruction source: `.github/copilot-instructions.md` (canonical when it conflicts with this file).

## Repo shape

- This repo builds cpuminer-opt from source via `git clone` in the Dockerfile; it does not use prebuilt tarballs.
- `Dockerfile` is the single image variant (no multi-stage variants).
- Default `docker run` uses `CMD ["cpuminer", "--config=config.json"]` directly — no entrypoint script.
- The image runs as non-root `cpuminer` by default.
- The Dockerfile uses `-march=native`; images built on one CPU may not run on another. Review this before publishing portable images.

## Verification

- Primary checks are Docker-based:
  - `docker build . -t cniweb/cpuminer-opt:test`
  - `docker run --rm cniweb/cpuminer-opt:test cpuminer --version`
  - `docker run --rm cniweb/cpuminer-opt:test cpuminer --cputest`
- `./build.sh build-only` is the same build path CI uses on `main`; it exits before registry login, security checks, or pushes.
- `./security-check.sh` defaults to image `cniweb/cpuminer-opt:test`; build that tag first or pass a different image name.
- Note: CI tags the image as `docker.io/cniweb/cpuminer-opt:<version>` (version taken from `build.sh`), while the manual quick-start above uses `:test`. Pass the matching name to `security-check.sh`.
- CI and Dockerfile checks are the test surface; there is no conventional unit-test or lint suite.

## Shell and runtime constraints

- Build scripts (`build.sh`, `security-check.sh`) are `bash` scripts with `set -eu`; keep them POSIX-compatible where possible.
- Port `8080` is the expected HTTP/API port across the Dockerfile, agent docs, and checks (`README.md` currently states no port).
- The image runs as non-root `cpuminer` (uid=1000) by default.

## Release/versioning

- cpuminer-opt uses two-component versioning (e.g. `26.1` — no patch number).
- Version bumps must stay synchronized across all four files: `Dockerfile`, `build.sh`, `README.md`, and `CHANGELOG.md`.
- Caveat: `README.md` currently contains no version strings matching the workflow's regexes (`` `Dockerfile` currently uses cpuminer-opt `X`. `` etc.), so that step is a silent no-op until such refs are added. If you add version refs to `README.md`, they must match those patterns or the workflow will silently skip them.
- The release workflow (`.github/workflows/release-from-version.yml`) handles all four automatically: it updates version refs, and promotes `CHANGELOG.md`'s `## [Unreleased]` heading to `## [<version>] - <date>`. **The workflow fails fast if `CHANGELOG.md` has no `## [Unreleased]` section** — add one with the release notes before triggering it.
- Prefer that workflow for releases: it updates version refs, commits, tags `vX.Y`, and creates the GitHub release.
- The `Dockerfile` uses `ARG VERSION_TAG=v$version` (with `v` prefix), while `build.sh` uses `version="26.1"` (without `v` prefix).

## Small gotchas

- Since cpuminer-opt is built from source via git clone, the Docker build takes 60-90 seconds.
- `.dockerignore` excludes `.github`, `build.sh`, and `security-check.sh` from the build context (plus git metadata, docs, IDE/log files — see the file for the full list).
- No `docker-entrypoint.sh` exists — the container uses `CMD` directly.
- The runtime config is `/home/cpuminer/config.json`; offline validation should use `--version` or `--cputest` rather than the default mining command.
- `build.sh` uses `set -u` and currently references registry credential variables before safe defaults in full mode. Preserve or fix this deliberately; the README's skip-missing-registry behavior depends on it.
- Keep the Dockerfile's `v`-prefixed `VERSION_TAG` distinct from the unprefixed version stored by `build.sh`. Review the unused/misspelled `extracflags` variable when changing compiler flags.

## CI

- `.github/workflows/docker-image.yml` runs on push and PR to `main`:
  - `validate` job: builds with `./build.sh build-only`, then runs `cpuminer --version`, `cpuminer --cputest`, and `security-check.sh` against it. Never pushes.
  - `docker` job (push events only, gated on `validate` passing): rebuilds, re-runs validation against the exact image about to ship, then tags and pushes versioned + `latest` + commit-SHA tags to Docker Hub and GHCR, and generates a SLSA provenance attestation and SBOM.
  - Removed Quay.io references from CI and build defaults (unused registry).
- Snyk container scanning runs on push/PR to `main` and weekly via `snyk-container-analysis.yml`.
- Dependabot monitors Docker base images and GitHub Actions versions.

## Lessons Learned

- Process: when a session proves a repo fact this file missed or misstated, append a dated entry here (`YYYY-MM-DD` — observation + how it was verified). Promote recurring entries into the sections above and drop the entry once merged, so the file improves itself.
- 2026-09-24 — Merging Dependabot PRs: check `gh pr view --json mergeable,mergeStateStatus` (want `MERGEABLE`/`CLEAN`) plus green checks, merge sequentially, re-check after each merge (`UNKNOWN` right after a merge is normal — wait ~10s and re-query), then `git pull --ff-only origin main` to sync local. Verified merging PR #39 + #42.
- 2026-09-24 — Upstream version checks: `gh release list --repo JayDDee/cpuminer-opt` (date-sorted, honors the `Latest` marker) plus `gh api repos/JayDDee/cpuminer-opt/compare/vX.Y...HEAD` beat numeric tag sorting — tag `v27.4` is a mistagged Dec-2024 `24.7` release, not a newer version. Current pin `v26.1` is latest; upstream `master` HEAD is identical.
- 2026-09-24 — `.gitignore` is not the build context: gitignored-but-untracked dirs (e.g. `.serena/`) are still sent to the Docker daemon unless also listed in `.dockerignore`. Follow-up: add `.serena/` there.
- 2026-09-24 — Open cross-file contradictions (fix in the source files, then delete this entry): `.github/copilot-instructions.md` calls `AGENTS.md` canonical, contradicting this file's header; `.github/prompts/create-release.prompt.md` claims the release workflow does not touch `CHANGELOG.md`, but it promotes `## [Unreleased]`; `README.md` has no version refs for the workflow's README regexes.
