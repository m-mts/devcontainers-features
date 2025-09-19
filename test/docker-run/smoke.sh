#!/usr/bin/env bash
set -euo pipefail

# Smoke test for src/docker-run/install.sh
# Creates a temporary docker stub, runs install.sh with IMAGES env value,
# and asserts the expected docker commands were invoked.

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
INSTALL_SH="$ROOT_DIR/src/docker-run/install.sh"
TMP_DIR="/tmp/docker-run-feature-test-$$"
mkdir -p "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT

# docker stub: echo invoked command for assertions
cat > "$TMP_DIR/docker" <<'SH'
#!/usr/bin/env bash
printf "[docker-stub] "; printf "%q " "$@"; echo
SH
chmod +x "$TMP_DIR/docker"

# Prepare IMAGES env: include an image name and an options-prefixed entry
IMAGES='hello-world,--rm -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 postgres:latest'

OUTPUT=$(PATH="$TMP_DIR:$PATH" IMAGES="$IMAGES" bash "$INSTALL_SH" 2>&1 || true)

echo "--- install.sh output ---"
echo "$OUTPUT"
echo "--- end output ---"

# Assertions: expect hello-world run and postgres run with env/port
if ! grep -q "\[docker-stub\].*run --rm hello-world" <<< "$OUTPUT"; then
    echo "Expected hello-world run not found"
    exit 1
fi
if ! grep -q "\[docker-stub\].*run --rm -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 postgres:latest" <<< "$OUTPUT"; then
    echo "Expected postgres run with env/port not found"
    exit 1
fi

echo "SMOKE TEST: PASS"