# cpuminer-opt

High performance, open source CPU/GPU Miner Docker Image for some mininer algoritms with AES, AVX, AVX2, SHA, AVX512 and VAES.

[![Snyk Container](https://github.com/cniweb/cpuminer-opt-docker/actions/workflows/snyk-container-analysis.yml/badge.svg)](https://github.com/cniweb/cpuminer-opt-docker/actions/workflows/snyk-container-analysis.yml) [![Docker Image CI](https://github.com/cniweb/cpuminer-opt-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/cniweb/cpuminer-opt-docker/actions/workflows/docker-image.yml) ![Docker Pulls](https://img.shields.io/docker/pulls/cniweb/cpuminer-opt)

## Usage from ghcr.io

```bash
docker run ghcr.io/cniweb/cpuminer-opt:latest
```

<https://github.com/cniweb/cpuminer-opt-docker/pkgs/container/cpuminer-opt>

## Usage from Docker.io

```bash
docker run cniweb/cpuminer-opt:latest
```

## Usage from Quay.io

```bash
docker run quay.io/cniweb/cpuminer-opt:latest
```

## Development and CI/CD

### GitHub Secrets Configuration

To enable automated Docker image building and pushing to multiple registries, configure the following GitHub Secrets in your repository settings:

#### Required Secrets for Registry Access:

1. **Docker Hub (docker.io)**:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub password or access token

2. **GitHub Container Registry (ghcr.io)**:
   - `GITHUB_TOKEN`: Automatically provided by GitHub Actions with `packages: write` permission configured in the workflow
   - No manual secret configuration needed - the workflow automatically grants the necessary permissions

3. **Quay.io**:
   - `QUAY_USERNAME`: Your Quay.io username
   - `QUAY_PASSWORD`: Your Quay.io password or robot token

#### How to Configure Secrets:

1. Go to your repository on GitHub
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the exact name shown above

**Note**: For GitHub Container Registry, the `GITHUB_TOKEN` is automatically provided by GitHub Actions and configured with the necessary `packages: write` permission in the workflow file. No manual configuration is required.

#### Registry Behavior:

- The build script will automatically detect which registry credentials are available
- If credentials for a registry are missing, that registry will be skipped
- At least one registry must be configured for the build to proceed
- The build will fail if no valid registry credentials are provided

#### Manual Building:

You can also run the build script locally by setting the appropriate environment variables:

```bash
export DOCKER_USERNAME="your_username"
export DOCKER_PASSWORD="your_password"
export GITHUB_TOKEN="your_github_token"
export QUAY_USERNAME="your_quay_username"
export QUAY_PASSWORD="your_quay_password"

./build.sh
```
