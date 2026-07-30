# cpuminer-opt-docker

cpuminer-opt-docker builds cpuminer-opt from source in a Debian environment and publishes Docker images to Docker Hub and GitHub Container Registry.

## Project Structure

Dockerfile              # Single-stage build from git source
build.sh                # Build and push script
security-check.sh       # Image security verification
AGENTS.md               # Primary agent workspace guide (canonical)

## Working Effectively

### Quick Start

docker build . -t cniweb/cpuminer-opt:test
docker run --rm cniweb/cpuminer-opt:test cpuminer --version
docker run --rm cniweb/cpuminer-opt:test cpuminer --cputest

### Bootstrap and Build

- Docker build: 60-90 seconds (clean). NEVER CANCEL. Set timeout to 120+ seconds.
- Cached build: <1 second when layers are cached.
- Builds from git: git clone + git checkout VERSION_TAG + autogen.sh + configure + make
- Uses Debian trixie-slim base image

### Versioning

- Two-component versioning: 25.6 (no patch number)
- Default VERSION_TAG=v25.6 (Dockerfile) / version="25.6" (build.sh)
- Version bumps across: Dockerfile, build.sh, README.md, CHANGELOG.md

## Environment Variables

ENV VAR               Default                    Description
ALGO                  yespower                   Mining algorithm
POOL_ADDRESS          stratum+tcp://...6533       Pool URL
WALLET_USER           YOUR_WALLET_ADDRESS        Wallet address
PASSWORD              x                          Pool password

## CI/CD Pipeline

- docker-image.yml: Build, validate, push with SLSA + SBOM (on push/PR to main)
- release-from-version.yml: Automated releases from version bump
- snyk-container-analysis.yml: Snyk vulnerability scanning
- Dependabot: Monitors base image + Actions versions

## Tips

- Run security check: ./security-check.sh (defaults to cniweb/cpuminer-opt:test)
- Build only: ./build.sh build-only (skips login/push)
- The image runs as non-root `cpuminer` user, port 8080
