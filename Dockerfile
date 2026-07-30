FROM debian:trixie-slim

# Set non-root user early
ARG VERSION_TAG=v26.1
ARG CPUMINER_USER=cpuminer
ARG CPUMINER_UID=1000
ARG CPUMINER_GID=1000

# Environment variables for mining configuration
ENV ALGO="yespower"
ENV POOL_ADDRESS="stratum+tcp://yespower.eu.mine.zergpool.com:6533"
ENV WALLET_USER="YOUR_WALLET_ADDRESS"
ENV PASSWORD="x"

# Create non-root user and group
RUN set -eu; \
    groupadd -g ${CPUMINER_GID} ${CPUMINER_USER} \
    && useradd -u ${CPUMINER_UID} -g ${CPUMINER_GID} -m -s /usr/sbin/nologin ${CPUMINER_USER}

# Install build and runtime dependencies
RUN set -eu; \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        ca-certificates \
        curl \
        g++ \
        git \
        libcurl4-openssl-dev \
        libgmp-dev \
        libjansson-dev \
        libssl-dev \
        libz-dev \
        make \
        pkg-config \
    && update-ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Compile cpuminer-opt from source
RUN set -eu; \
    git clone --recursive https://github.com/JayDDee/cpuminer-opt.git /tmp/cpuminer \
    && cd /tmp/cpuminer \
    && git checkout "$VERSION_TAG" \
    && ./autogen.sh \
    && extracflags="-Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores" \
    && CFLAGS="-O3 -march=native -Wall" ./configure --with-curl \
    && make install -j 4 \
    && cd / \
    && apt-get purge --auto-remove -y \
        autoconf \
        automake \
        curl \
        g++ \
        git \
        make \
        pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* \
    && cpuminer --cputest \
    && cpuminer --version

# Switch to non-root user
USER ${CPUMINER_USER}
WORKDIR /home/${CPUMINER_USER}

# Copy configuration
COPY --chown=${CPUMINER_USER}:${CPUMINER_USER} config.json /home/${CPUMINER_USER}/

# Use non-privileged port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD cpuminer --version > /dev/null 2>&1 || exit 1

CMD ["cpuminer", "--config=config.json"]
