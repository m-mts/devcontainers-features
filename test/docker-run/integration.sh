#!/usr/bin/env bash
set -euo pipefail

# integration.sh
# Run src/docker-run/install.sh inside a disposable Docker container to exercise real docker usage.
# Note: This test requires Docker on the host and will invoke docker inside the container only if the image provides it.

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
INSTALL_SH="/work/src/docker-run/install.sh"
IMAGE="alpine:3.18"

usage() {
  cat <<EOF
Usage: $0 [--images CSV] [--image IMAGE]

Runs an integration test by invoking src/docker-run/install.sh inside a disposable Docker container.

Options:
  --images CSV   Comma-separated images/commands to run (default: 'hello-world')
  --image IMAGE  Docker image to use for the test (default: ${IMAGE})
  -h, --help     Show this help

Example:
  $0 --images 'hello-world'

Note: This may require Docker and network access. The container is removed after the test.
EOF
}

IMAGES='hello-world'

while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --images)
      IMAGES="$2"; shift 2;;
    --image)
      IMAGE="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not in PATH. Install Docker to run this integration test." >&2
  exit 3
fi

echo "Running integration test in image: $IMAGE"

# Run container with repo mounted at /work and IMAGES env passed in
set -x
docker run --rm -v "$ROOT_DIR":/work -w /work -e IMAGES="$IMAGES" "$IMAGE" sh -lc "chmod +x $INSTALL_SH && bash $INSTALL_SH"
set +x

echo "Integration run complete (container removed)."

exit 0
