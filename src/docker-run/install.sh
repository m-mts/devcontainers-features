#!/usr/bin/env bash
set -euo pipefail
shopt -s nocasematch

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="$DIR/devcontainer-feature.json"

echo "Running docker images"

# Accept first arg, then IMAGES, then PACKAGES as fallbacks
INPUT="${1:-${IMAGES:-${PACKAGES:-}}}"

if [ -z "$INPUT" ]; then
    # Try to extract proposals from devcontainer-feature.json (images key)
    if [ -f "$JSON_FILE" ] && command -v python3 >/dev/null 2>&1; then
        INPUT=$(python3 -c "import json,sys;print(','.join(json.load(open(\"$JSON_FILE\"))['options'].get('images',{}).get('proposals',[])))")
    fi
fi

if [ -z "$INPUT" ]; then
    echo "No images specified and no proposals found in $JSON_FILE."
    echo "Usage: $0 \"image1,image2\"  (or set IMAGES or PACKAGES env var)"
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo "docker command not found in PATH. Skipping docker run steps." >&2
    echo "All requested docker runs skipped because docker CLI is not available." 
    exit 0
fi

# Check Docker daemon connectivity. In some build contexts the docker CLI
# exists but cannot reach the daemon (e.g., during image build). If the
# daemon is not reachable, skip running images rather than failing the
# entire feature installation.
if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon is not reachable (docker info failed). Skipping docker run steps." >&2
    echo "All requested docker runs skipped because Docker daemon is unavailable." 
    exit 0
fi

IFS=',' read -r -a items <<< "$INPUT"
for raw in "${items[@]}"; do
    # trim whitespace
    pkg="$(echo "$raw" | sed -e 's/^\s*//' -e 's/\s*$//')"
    [ -z "$pkg" ] && continue

    # Decide how to run: full 'docker ...' left as-is, leading params prefixed with 'docker run', plain image names get '--rm'
    if [[ "$pkg" =~ ^docker[[:space:]]+ ]]; then
        cmd="$pkg"
    elif [[ "$pkg" =~ ^- ]]; then
        cmd="docker run $pkg"
    else
        cmd="docker run --rm $pkg"
    fi

    echo "+ $cmd"
    # shellcheck disable=SC2086
    eval "$cmd"
done

echo "All requested docker runs completed."
