#!/bin/bash
version="3.16.3"
image="cpuminer-opt"
docker build . --tag docker.io/cniweb/$image:$version
docker tag docker.io/cniweb/$image:$version ghcr.io/cniweb/$image:$version
docker tag docker.io/cniweb/$image:$version ghcr.io/cniweb/$image:latest
docker tag docker.io/cniweb/$image:$version docker.io/cniweb/$image:latest
docker push ghcr.io/cniweb/$image:$version
docker push ghcr.io/cniweb/$image:latest
docker push docker.io/cniweb/$image:$version
docker push docker.io/cniweb/$image:latest