# cpuminer-opt-docker

cpuminer-opt-docker is a containerized cryptocurrency miner that builds cpuminer-opt from source in a Debian environment. It creates optimized Docker images for CPU mining across multiple registries.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Quick Start - Use Pre-built Image (RECOMMENDED)
- Pull and test the pre-built image: `docker pull cniweb/cpuminer-opt:latest` -- takes 30 seconds
- Test functionality: `docker run --rm cniweb/cpuminer-opt:latest cpuminer --version`
- Run with help: `docker run --rm cniweb/cpuminer-opt:latest cpuminer --help`

### Bootstrap and Build the Container
- **NEVER CANCEL: Docker build takes 60-90 seconds. NEVER CANCEL. Set timeout to 120+ seconds.**
- **SSL ISSUE RESOLVED**: The current Dockerfile includes SSL workaround and builds successfully.

#### Standard Build
- Build the Docker image:
  ```bash
  cd /home/runner/work/cpuminer-opt-docker/cpuminer-opt-docker
  docker build . --tag cpuminer-opt:latest --build-arg VERSION_TAG=v25.6
  ```
- **If build fails with SSL certificate errors** (in some restricted environments), use this workaround:
  ```bash
  # Create temporary Dockerfile with additional SSL workaround
  sed 's/git clone --recursive/git config --global http.sslverify false \&\& git clone --recursive/' Dockerfile > /tmp/Dockerfile.ssl-fix
  docker build -f /tmp/Dockerfile.ssl-fix . --tag cpuminer-opt:latest --build-arg VERSION_TAG=v25.6
  ```

#### Advanced Build (Complete SSL Workaround)
For comprehensive SSL fixes, create a complete fixed Dockerfile:
```bash
# Create fixed Dockerfile with SSL workaround
cat > /tmp/Dockerfile.fixed << 'EOF'
FROM debian:trixie-slim
ARG VERSION_TAG=v25.6
RUN set -x \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y \
    autoconf automake ca-certificates curl g++ git \
    libcurl4-openssl-dev libgmp-dev libjansson-dev \
    libssl-dev libz-dev make pkg-config \
 && update-ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
RUN set -x \
 && git config --global http.sslVerify false \
 && git clone --recursive https://github.com/JayDDee/cpuminer-opt.git /tmp/cpuminer \
 && cd /tmp/cpuminer \
 && git checkout "$VERSION_TAG" \
 && ./autogen.sh \
 && extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores" \
 && CFLAGS="-O3 -march=native -Wall" ./configure --with-curl \
 && make install -j 4 \
 && cd / \
 && apt-get purge --auto-remove -y autoconf automake curl g++ git make pkg-config \
 && apt-get clean && apt-get -y autoremove --purge && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* \
 && cpuminer --cputest && cpuminer --version
WORKDIR /cpuminer
COPY config.json /cpuminer
EXPOSE 80
CMD ["cpuminer", "--config=config.json"]
EOF

# Build the image -- takes 65 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
docker build -f /tmp/Dockerfile.fixed . --build-arg VERSION_TAG=v25.6 --tag cpuminer-opt:latest
```

### Use the Build Script
- Build and tag for all registries:
  ```bash
  # Note: This script will attempt to push to registries - only run if you have push access
  ./build.sh
  ```
- The script builds for docker.io, ghcr.io, and quay.io with version 25.6
- **Note**: build.sh requires registry credentials (DOCKER_USERNAME, DOCKER_PASSWORD, GITHUB_TOKEN, QUAY_USERNAME, QUAY_PASSWORD)
- **Without credentials**: The script gracefully reports missing credentials and exits

### Run the Container
- Display help information:
  ```bash
  docker run --rm cpuminer-opt:latest cpuminer --help
  ```
- Run with default configuration (connects to mining pool):
  ```bash
  docker run --rm cpuminer-opt:latest
  ```
- **Note**: Default configuration attempts to connect to yespower.eu.mine.zergpool.com which may not be reachable in all environments
- Run benchmark mode (offline testing):
  ```bash
  docker run --rm cpuminer-opt:latest cpuminer --benchmark --algo=yespower --time-limit=10
  ```
- View version information:
  ```bash
  docker run --rm cpuminer-opt:latest cpuminer --version
  ```

## Validation

### Always Validate Changes
- **Build validation**: Always run the Docker build after making changes to ensure the image builds successfully
- **Runtime validation**: Test that the container starts and shows help information:
  ```bash
  docker run --rm cpuminer-opt:latest cpuminer --help
  ```
- **Benchmark validation**: Run a short benchmark to ensure the miner works:
  ```bash
  docker run --rm cpuminer-opt:latest cpuminer --benchmark --algo=yespower --time-limit=5
  ```
- **CI validation**: Check that GitHub workflows pass for Docker builds and security scanning

### Complete Validation Suite
**Always validate functionality after any changes**:
```bash
# Test version (should show v25.6 if built from source)
docker run --rm cpuminer-opt:latest cpuminer --version

# Test help output (shows supported algorithms)
docker run --rm cpuminer-opt:latest cpuminer --help

# Test CPU test functionality
docker run --rm cpuminer-opt:latest cpuminer --cputest

# Test mining configuration (will fail to connect to pool but validates config parsing)
timeout 30s docker run --rm cpuminer-opt:latest
```

### Expected Behavior
- **Build time**: Docker build completes in 60-90 seconds with source compilation (measured ~88 seconds)
- **Container startup**: Container starts immediately and displays cpuminer-opt 25.6 banner
- **Default behavior**: Container attempts to connect to mining pool and retries every 10 seconds if connection fails
- **Benchmark mode**: Reports hashrate (e.g., "Benchmark: 636.87 H/s") and exits cleanly
- **Validation results**:
  - `--version`: Shows cpuminer-opt version, CPU features (AVX2, VAES, SHA256), build info
  - `--help`: Lists 50+ supported mining algorithms (allium, anime, argon2, etc.)
  - `--cputest`: Runs silently and exits with code 0
  - Default run: Shows yespower algorithm, tries to connect to zergpool.com (fails due to network restrictions)

## Common Tasks

### Updating cpuminer-opt Version
- Update VERSION_TAG in build.sh
- Update VERSION_TAG build argument in Dockerfile
- Test build with new version:
  ```bash
  docker build . --build-arg VERSION_TAG=vNEW.VERSION --tag cpuminer-opt:test
  ```

### Modifying Mining Configuration
- Edit config.json to change:
  - Mining pool URL (`url`)
  - Wallet address (`user`) 
  - Mining algorithm (`algo`)
  - Thread count (`threads`)
- Always test configuration changes:
  ```bash
  docker run --rm cpuminer-opt:latest cpuminer --config=/cpuminer/config.json --time-limit=10
  ```

### Troubleshooting Build Issues
- **SSL/certificate errors**: Use the SSL workaround documented above
- **Out of memory during build**: The build uses `make install -j 4` which may require sufficient RAM
- **Missing dependencies**: All required build dependencies are installed in the Dockerfile's first RUN layer

### Additional Troubleshooting

#### SSL Certificate Issues
**Problem**: `fatal: unable to access 'https://github.com/JayDDee/cpuminer-opt.git/': server verification failed`

**Solution**: Add `git config --global http.sslVerify false` before git clone in Dockerfile

#### Build Failures
- **Current Dockerfile works out of the box** with built-in SSL workaround
- **Set Docker build timeout to 120+ seconds** - builds take ~88 seconds
- **Only use additional SSL workarounds** if build fails in extremely restricted environments

#### Mining Connection Issues
- Default config tries to connect to external mining pool
- Connection failures are expected in restricted network environments
- Pool connections are for testing/demonstration only

## Repository Structure

```
.
├── .dockerignore          # Files excluded from Docker build context
├── .github/
│   └── workflows/
│       ├── docker-image.yml          # CI build workflow (FAILS due to SSL)
│       └── snyk-container-analysis.yml  # Security scanning
├── Dockerfile             # Multi-stage build definition (SSL workaround included)
├── LICENSE                # Apache 2.0 license
├── README.md              # Basic usage documentation  
├── build.sh               # Multi-registry build and push script (requires credentials)
├── config.json            # Default mining configuration (yespower algorithm)
└── .whitesource           # WhiteSource configuration
```

### Key Files
- **Dockerfile**: Builds cpuminer-opt v25.6 from github.com/JayDDee/cpuminer-opt with optimizations
- **config.json**: Contains mining pool configuration for yespower algorithm
- **build.sh**: Automates building and pushing to docker.io, ghcr.io, and quay.io
- **.github/workflows/docker-image.yml**: CI pipeline that builds Docker image on push/PR
- **.github/workflows/snyk-container-analysis.yml**: Security vulnerability scanning

### Key Configuration Files

#### config.json (mining configuration)
```json
{
  "api-bind": "127.0.0.1:80",
  "url": "stratum+tcp://yespower.eu.mine.zergpool.com:6533",
  "user": "LNec6RpZxX6Q1EJYkKjUPBTohM7Ux6uMUy",
  "pass": "c=LTC,id=docker",
  "algo": "yespower",
  "threads": 4,
  "no-color": true
}
```

### Build Process Details
1. Starts from debian:trixie-slim base image
2. Installs build dependencies (autoconf, automake, gcc, git, libcurl, etc.)
3. Clones cpuminer-opt source code from GitHub
4. Compiles with optimizations: -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores
5. Installs binary and cleans up build dependencies
6. Copies config.json and sets up runtime environment
7. Exposes port 80 for API access
8. Sets default command to run with config file

### Build Infrastructure

#### GitHub Workflows
- `docker-image.yml`: Basic Docker build CI (FAILS due to SSL certificate issue)
- `snyk-container-analysis.yml`: Security scanning with complex SARIF patching

**Known CI Issues**:
- Docker builds may fail in GitHub Actions due to SSL certificate verification in some environments
- Original build.sh script requires registry credentials to push images
- Snyk workflow has extensive SARIF patching for null security-severity values

### Docker Configuration
- **Base image**: debian:trixie-slim
- **Exposed port**: 80 (mining API)
- **Working directory**: /cpuminer
- **Default command**: `cpuminer --config=config.json`

### Supported Algorithms
The miner supports 80+ algorithms including: yespower, scrypt, sha256d, x11, x16r, neoscrypt, lyra2re, and many others. See `cpuminer --help` for the complete list.

## Version Information
- **cpuminer-opt version**: v25.6 (when built from source)
- **Pre-built image version**: v25.1 
- **Base image**: debian:trixie-slim
- **Supported algorithms**: 50+ including yespower, scrypt, x11, sha256d
- **CPU optimizations**: AVX2, VAES, SHA256, SSE2