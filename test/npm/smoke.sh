#!/usr/bin/env bash
set -euo pipefail

# Smoke test for src/npm/install.sh
# Creates temporary node/npm stubs, runs install.sh with a JSON PACKAGES value,
# and asserts the expected npm commands were invoked.

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
INSTALL_SH="$ROOT_DIR/src/npm/install.sh"
TMP_DIR="/tmp/npm-feature-test-$$"
mkdir -p "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT

# node stub: parse PACKAGES JSON and print pkg|global|version lines
cat > "$TMP_DIR/node" <<'PY'
#!/usr/bin/env bash
python3 - <<'PYCODE'
import os, json, sys
input = os.environ.get('PACKAGES','')
try:
    arr = json.loads(input)
except Exception:
    sys.exit(2)
if not isinstance(arr, list):
    sys.exit(3)
for o in arr:
    pkg = o.get('package') or o.get('name') or ''
    global_ = o.get('global', True)
    version = o.get('version', 'latest')
    if not pkg:
        continue
    print(f"{pkg}|{global_}|{version}")
PYCODE
PY
chmod +x "$TMP_DIR/node"

# npm stub: echo invoked command
cat > "$TMP_DIR/npm" <<'SH'
#!/usr/bin/env bash
# Print a visible prefix for assertions
printf "[npm-stub] "; printf "%q " "$@"; echo
SH
chmod +x "$TMP_DIR/npm"

# Run the install script using the stubs in PATH
PACKAGES='[{"package":"typescript","global":true,"version":"latest"},{"package":"nodemon","global":false,"version":"2.0.0"}]'
OUTPUT=$(PATH="$TMP_DIR:$PATH" PACKAGES="$PACKAGES" bash "$INSTALL_SH" 2>&1 || true)

echo "--- install.sh output ---"
echo "$OUTPUT"
echo "--- end output ---"

# Assertions: expect global typescript install and local nodemon install
if ! grep -qE "\\[npm-stub\\].*install -g typescript\b" <<< "$OUTPUT"; then
    echo "Expected global typescript install not found"
    exit 1
fi
if ! grep -qE "\\[npm-stub\\].*install nodemon@2.0.0\b" <<< "$OUTPUT"; then
    echo "Expected local nodemon install not found"
    exit 1
fi

echo "SMOKE TEST: PASS"
