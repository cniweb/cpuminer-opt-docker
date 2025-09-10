#!/bin/bash
# Define image name, version and registries
image="cpuminer-opt"
version="25.6"
registries=("docker.io" "ghcr.io" "quay.io")

# Build the image
docker build . --build-arg VERSION_TAG=v$version --tag ${registries[0]}/cniweb/$image:$version

# Check if the command was successful
if [ $? -ne 0 ]; then
  echo "Docker build failed!"
  exit 1
fi

echo "Docker build succeeded!"

# Tag and push the images
for registry in "${registries[@]}"; do
  docker tag ${registries[0]}/cniweb/$image:$version $registry/cniweb/$image:$version
  docker tag ${registries[0]}/cniweb/$image:$version $registry/cniweb/$image:latest
  
  # Push both versioned and latest tags
  docker push $registry/cniweb/$image:$version
  docker push $registry/cniweb/$image:latest
done
