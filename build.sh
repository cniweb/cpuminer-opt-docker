#!/bin/bash

docker build . --tag cniweb/cpuminer-opt:3.15.5
docker tag cniweb/cpuminer-opt:3.15.5 cniweb/cpuminer-opt:latest
docker push cniweb/cpuminer-opt:3.15.5
docker push cniweb/cpuminer-opt:latest