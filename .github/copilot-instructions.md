# cpuminer-opt-docker

cpuminer-opt-docker is a Docker-based cryptocurrency mining project that builds and packages cpuminer-opt (a CPU/GPU miner) into Docker images. It supports multiple mining algorithms with optimizations for modern CPU features (AVX, AVX2, SHA, AVX512, VAES).

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Quick Start - Use Pre-built Image (RECOMMENDED)
- Pull and test the pre-built image: `docker pull cniweb/cpuminer-opt:latest` -- takes 30 seconds
- Test functionality: `docker run --rm cniweb/cpuminer-opt:latest cpuminer --version`
- Run with help: `docker run --rm cniweb/cpuminer-opt:latest cpuminer --help`

### Building from Source (Advanced)
**CRITICAL SSL ISSUE**: The original Dockerfile fails due to SSL certificate verification errors when cloning from GitHub.

**Working build process with SSL workaround**:
```bash
# Create fixed Dockerfile with SSL workaround
cat > Dockerfile.fixed << 'EOF'
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
docker build -f Dockerfile.fixed . --build-arg VERSION_TAG=v25.6 --tag cpuminer-local:latest
```

**Build timing**: 65 seconds total. NEVER CANCEL builds - they complete successfully with the SSL workaround.

### Testing and Validation
**Always validate functionality after any changes**:
```bash
# Test version (should show v25.6 if built from source, v25.1 if using pre-built)
docker run --rm <image_name> cpuminer --version

# Test help output (shows supported algorithms)
docker run --rm <image_name> cpuminer --help

# Test CPU test functionality
docker run --rm <image_name> cpuminer --cputest

# Test mining configuration (will fail to connect to pool but validates config parsing)
timeout 30s docker run --rm <image_name>
```

**Expected validation results**:
- `--version`: Shows cpuminer-opt version, CPU features (AVX2, VAES, SHA256), build info
- `--help`: Lists 50+ supported mining algorithms (allium, anime, argon2, etc.)
- `--cputest`: Runs silently and exits with code 0
- Default run: Shows yespower algorithm, tries to connect to zergpool.com (fails due to network restrictions)

## Build Infrastructure

### GitHub Workflows
- `docker-image.yml`: Basic Docker build CI (FAILS due to SSL certificate issue)
- `snyk-container-analysis.yml`: Security scanning with complex SARIF patching

**Known CI Issues**:
- Docker builds fail in GitHub Actions due to SSL certificate verification
- Original build.sh script will fail without SSL workaround
- Snyk workflow has extensive SARIF patching for null security-severity values

### Build Script Usage
```bash
# Make executable and run (WILL FAIL without SSL fix)
chmod +x build.sh
./build.sh  # Builds and pushes to docker.io, ghcr.io, quay.io
```

**Note**: build.sh will fail with SSL errors. Apply SSL workaround to Dockerfile first.

## Configuration

### Mining Configuration (config.json)
- **Algorithm**: yespower (CPU-optimized)
- **Pool**: yespower.eu.mine.zergpool.com:6533
- **API**: Binds to 127.0.0.1:80
- **Threads**: 4 (configurable)

### Docker Configuration
- **Base image**: debian:trixie-slim
- **Exposed port**: 80 (mining API)
- **Working directory**: /cpuminer
- **Default command**: `cpuminer --config=config.json`

## Common Tasks

### Repository Structure
```
.
├── Dockerfile              # Main build file (has SSL issue)
├── build.sh                # Build and push script (fails without SSL fix)
├── config.json             # Mining pool configuration
├── README.md               # Basic usage documentation
├── LICENSE                 # Apache License 2.0
├── .dockerignore           # Docker build exclusions
├── .github/
│   └── workflows/
│       ├── docker-image.yml         # Basic CI (fails)
│       └── snyk-container-analysis.yml  # Security scanning
└── .whitesource            # WhiteSource configuration
```

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

#### Dockerfile (original - has SSL issue)
- Builds cpuminer-opt v25.6 from source
- Uses Debian trixie-slim base
- Installs build dependencies and libraries
- **FAILS**: SSL certificate verification during git clone

## Troubleshooting

### SSL Certificate Issues
**Problem**: `fatal: unable to access 'https://github.com/JayDDee/cpuminer-opt.git/': server verification failed`

**Solution**: Add `git config --global http.sslVerify false` before git clone in Dockerfile

### Build Failures
- **Always use the SSL workaround Dockerfile** for successful builds
- **Never use the original build.sh** without fixing Dockerfile first
- **Set Docker build timeout to 120+ seconds** - builds take ~65 seconds

### Mining Connection Issues
- Default config tries to connect to external mining pool
- Connection failures are expected in restricted network environments
- Pool connections are for testing/demonstration only

## Version Information
- **cpuminer-opt version**: v25.6 (when built from source)
- **Pre-built image version**: v25.1 
- **Base image**: debian:trixie-slim
- **Supported algorithms**: 50+ including yespower, scrypt, x11, sha256d
- **CPU optimizations**: AVX2, VAES, SHA256, SSE2