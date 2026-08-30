#!/bin/bash

set -u

IMAGE="$1"

echo "Scanning image: $IMAGE"

trivy image \
  --severity HIGH,CRITICAL \
  "$IMAGE"

TRIVY_EXIT_CODE=$?

echo ""
echo "=========================================="
echo "Trivy scan completed."
echo "Trivy exit code: $TRIVY_EXIT_CODE"
echo "Vulnerabilities are reported above."
echo "Pipeline will continue for this demo."
echo "=========================================="

# Demo mode: do not fail pipeline because of vulnerabilities
exit 0
