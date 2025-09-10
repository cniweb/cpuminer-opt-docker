FROM debian:trixie-slim
ARG VERSION_TAG=v25.6
RUN set -x \
    # Runtime dependencies.
 && apt-get update \
 && apt-get upgrade -y \
    # Build dependencies.
 && apt-get install -y \
    autoconf \
    automake \
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
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
RUN set -x \
    # Compile from source code.
 && git config --global http.sslVerify false \
 && git clone --recursive https://github.com/JayDDee/cpuminer-opt.git /tmp/cpuminer \
 && cd /tmp/cpuminer \
 && git checkout "$VERSION_TAG" \
 && ./autogen.sh \
 && extracflags="$extracflags -Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores" \
 && CFLAGS="-O3 -march=native -Wall" ./configure --with-curl  \
 && make install -j 4 \
    # Clean-up
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
 && apt-get -y autoremove --purge \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
 && rm -rf /tmp/* \
    # Verify
 && cpuminer --cputest \
 && cpuminer --version

WORKDIR /cpuminer
COPY config.json /cpuminer
EXPOSE 80
CMD ["cpuminer", "--config=config.json"]
