#!/bin/bash

docker build . --tag cniweb/cpuminer-opt:3.16.2
#docker tag cniweb/cpuminer-opt:3.16.2 cniweb/cpuminer-opt:latest
#docker push cniweb/cpuminer-opt:3.16.2
#docker push cniweb/cpuminer-opt:latest
docker tag cniweb/cpuminer-opt:3.16.2 ghcr.io/cniweb/cpuminer-opt:3.16.2
docker tag cniweb/cpuminer-opt:3.16.2 ghcr.io/cniweb/cpuminer-opt:latest
docker push ghcr.io/cniweb/cpuminer-opt:3.16.2
docker push ghcr.io/cniweb/cpuminer-opt:latest