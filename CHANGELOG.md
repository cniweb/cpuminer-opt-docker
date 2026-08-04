# Changelog

All notable changes to this Docker packaging project are documented here.
Each entry tracks the upstream [cpuminer-opt](https://github.com/JayDDee/cpuminer-opt) version used and any packaging changes made in this repository.

## [Unreleased]

### CI/CD
- Replaced `docker-image.yml` with hardened `docker-image.yml` featuring two jobs: `validate` (build + test on every push/PR) and `docker` (push + SLSA attestation + SBOM on push events only).
- Added `release-from-version.yml` workflow for automated version bumps, commits, tagging, and GitHub releases.
- Added `dependabot.yml` monitoring Docker base images and GitHub Actions.
- Pinned `snyk/actions/docker` to commit `9adf32b...` (v1.0.0) instead of mutable `@master` tag.
- Pinned `actions/checkout@v4` to `de0fac2...` (v6) and `github/codeql-action/upload-sarif@v3` to `e46ed2c...` (v4).

### Security & bug fixes
- **HIGH**: Removed `--no-check-certificate` from git clone — TLS verification now enforced.
- **HIGH**: Changed `EXPOSE 80` to `EXPOSE 8080` — non-privileged port.
- Added non-root user (`cpuminer`, uid=1000) to Dockerfile — container no longer runs as root.
- Added `HEALTHCHECK` to Dockerfile.
- Added `set -eu` to all `RUN` commands in Dockerfile.
- Added `security-check.sh` script for automated security validation.

### Documentation & repo hygiene
- Added `AGENTS.md` with agent workspace guide.
- Added `CHANGELOG.md` with release history.
- Added `CODEOWNERS` with `* @cniweb`.
- Added pull request template.
- `build.sh` now supports `build-only` argument (build without registry login/push).

## [26.1] - 2026-07-30

### Changed
- Updated cpuminer-opt from 25.6 to 26.1

## [25.6] - 2025-01-14

### Packaging
- Initial release packaging cpuminer-opt v25.6.
- Dockerfile builds from source via git clone with AVX2/VAES optimizations.
- Multi-registry push support (Docker Hub, GHCR, Quay.io).

[26.1]: https://github.com/JayDDee/cpuminer-opt/releases/tag/v26.1
[25.6]: https://github.com/JayDDee/cpuminer-opt/releases/tag/v25.6
