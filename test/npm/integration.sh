#!/usr/bin/env bash
set -euo pipefail

# integration.sh
# Run src/npm/install.sh inside a disposable Docker container to perform real npm installs.
# This script mounts the repository into the container and runs the feature install script
# with a real `npm` (not stubbed). The container is removed afterwards.

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
INSTALL_SH="/work/src/npm/install.sh"
IMAGE="node:18-bullseye"

usage() {
  cat <<EOF
Usage: $0 [--packages JSON] [--image IMAGE]

Runs an integration test by invoking src/npm/install.sh inside a disposable Docker container.

Options:
  --packages JSON   JSON array string of package objects to install (default: '[{"package":"typescript","global":true,"version":"latest"}]')
  --image IMAGE     Docker image to use (default: ${IMAGE})
  --skip-cleanup    (no-op) kept for parity with smoke script; containers are ephemeral by default
  -h, --help        Show this help

Example:
  $0 --packages '[{"package":"typescript","global":true,"version":"latest"}]'

Note: This performs real network installs inside the container. Ensure you have Docker installed and running. The container runs ephemeral and is removed after the test.
EOF
}

PACKAGES="[{\"package\":\"typescript\",\"global\":true,\"version\":\"latest\"}]"

# parse args
while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --packages)
      PACKAGES="$2"; shift 2;;
    --image)
      IMAGE="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    --skip-cleanup)
      # placeholder for compatibility
      shift;;
    *)
      echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed or not in PATH. Install Docker to run this integration test." >&2
  exit 3
fi

echo "Running integration test in image: $IMAGE"

# Run container with repo mounted at /work and PACKAGES env passed in
# Execute install.sh from the mounted repo
set -x
docker run --rm -v "$ROOT_DIR":/work -w /work -e PACKAGES="$PACKAGES" "$IMAGE" bash -lc "chmod +x $INSTALL_SH && bash $INSTALL_SH"
set +x

echo "Integration run complete (container removed)."

echo "To inspect what was installed inside the container, run an interactive container and list global packages:"
echo "  docker run --rm -it -v \"$ROOT_DIR\":/work -w /work $IMAGE bash -lc 'npm list -g --depth=0'"

exit 0
