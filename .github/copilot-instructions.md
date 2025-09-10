# cpuminer-opt-docker

cpuminer-opt-docker is a containerized cryptocurrency miner that builds cpuminer-opt from source in a Debian environment. It creates optimized Docker images for CPU mining across multiple registries.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Bootstrap and Build the Container
- **NEVER CANCEL: Docker build takes 60-90 seconds. NEVER CANCEL. Set timeout to 120+ seconds.**
- Build the Docker image:
  ```bash
  cd /home/runner/work/cpuminer-opt-docker/cpuminer-opt-docker
  docker build . --tag cpuminer-opt:latest --build-arg VERSION_TAG=v25.6
  ```
- **If build fails with SSL certificate errors**, use this workaround for sandboxed environments:
  ```bash
  # Create temporary Dockerfile with SSL workaround
  sed 's/git clone --recursive/git config --global http.sslverify false \&\& git clone --recursive/' Dockerfile > /tmp/Dockerfile.ssl-fix
  docker build -f /tmp/Dockerfile.ssl-fix . --tag cpuminer-opt:latest --build-arg VERSION_TAG=v25.6
  ```

### Use the Build Script
- Build and tag for all registries:
  ```bash
  # Note: This script will attempt to push to registries - only run if you have push access
  ./build.sh
  ```
- The script builds for docker.io, ghcr.io, and quay.io with version 25.6

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

### Expected Behavior
- **Build time**: Docker build completes in 60-90 seconds with source compilation
- **Container startup**: Container starts immediately and displays cpuminer-opt 25.6 banner
- **Default behavior**: Container attempts to connect to mining pool and retries every 10 seconds if connection fails
- **Benchmark mode**: Reports hashrate (e.g., "Benchmark: 636.87 H/s") and exits cleanly

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

## Repository Structure

```
.
├── .dockerignore          # Files excluded from Docker build context
├── .github/
│   └── workflows/
│       ├── docker-image.yml          # CI build workflow
│       └── snyk-container-analysis.yml  # Security scanning
├── Dockerfile             # Multi-stage build definition
├── LICENSE                # Apache 2.0 license
├── README.md              # Basic usage documentation  
├── build.sh               # Multi-registry build and push script
└── config.json            # Default mining configuration (yespower algorithm)
```

### Key Files
- **Dockerfile**: Builds cpuminer-opt v25.6 from github.com/JayDDee/cpuminer-opt with optimizations
- **config.json**: Contains mining pool configuration for yespower algorithm
- **build.sh**: Automates building and pushing to docker.io, ghcr.io, and quay.io
- **.github/workflows/docker-image.yml**: CI pipeline that builds Docker image on push/PR
- **.github/workflows/snyk-container-analysis.yml**: Security vulnerability scanning

### Build Process Details
1. Starts from debian:trixie-slim base image
2. Installs build dependencies (autoconf, automake, gcc, git, libcurl, etc.)
3. Clones cpuminer-opt source code from GitHub
4. Compiles with optimizations: -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores
5. Installs binary and cleans up build dependencies
6. Copies config.json and sets up runtime environment
7. Exposes port 80 for API access
8. Sets default command to run with config file

### Supported Algorithms
The miner supports 80+ algorithms including: yespower, scrypt, sha256d, x11, x16r, neoscrypt, lyra2re, and many others. See `cpuminer --help` for the complete list.