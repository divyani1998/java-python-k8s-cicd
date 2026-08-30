#!/bin/bash

# Container image security scan.
# Trivy is an open-source security scanner maintained by Aqua Security.

set -e

IMAGE_NAME="$1"

if [ -z "$IMAGE_NAME" ]; then
    echo "Usage: ./scripts/scan-image.sh <image>"
    exit 1
fi

echo "Scanning image: $IMAGE_NAME"

trivy image \
    --severity HIGH,CRITICAL \
    --exit-code 1 \
    "$IMAGE_NAME"

echo "Container scan completed successfully."
