#!/usr/bin/env bash
set -euo pipefail
shopt -s nocasematch

echo "Installing npm packages from PACKAGES..."

# PACKAGES is expected to be a JSON string representing an array of objects:
# [ { "package": "name", "global": true, "version": "latest" }, ... ]
# Alternatively it can be a comma-separated list of package names, or empty.

install_pkg() {
	local name="$1"
	local global="$2"
	local version="$3"

	local pkgspec="$name"
	if [[ -n "$version" && "$version" != "latest" ]]; then
		pkgspec+="@$version"
	fi

	if [[ "$global" == "true" ]]; then
		echo "npm install -g $pkgspec"
		npm install -g "$pkgspec"
	else
		echo "npm install $pkgspec"
		npm install "$pkgspec"
	fi
}

# Try to parse PACKAGES as JSON array
if [[ -n "${PACKAGES:-}" ]]; then
	# Detect if it's JSON (starts with [)
	first_char="${PACKAGES#${PACKAGES%%?}}"
	if [[ "${PACKAGES// /}" =~ ^\[ ]]; then
		# Use node to parse and emit lines: package|global|version
		mapfile -t entries < <(node -e '
const input = process.env.PACKAGES || "";
let arr;
try { arr = JSON.parse(input); } catch(e) { process.exit(2); }
if (!Array.isArray(arr)) process.exit(3);
for (const o of arr) {
  const pkg = o.package || o.name || "";
  const global = (typeof o.global === "undefined") ? true : !!o.global;
  const version = o.version || "latest";
  if (!pkg) continue;
  console.log(`${pkg}|${global}|${version}`);
}
') || true

	if [[ ${#entries[@]} -gt 0 ]]; then
		for e in "${entries[@]}"; do
			IFS='|' read -r pkg g v <<< "$e"
			install_pkg "$pkg" "$g" "$v"
		done
		exit 0
	fi
	echo "PACKAGES was JSON but produced no valid entries, falling back..."
	fi
	# close outer PACKAGES check
	fi

# If PACKAGES is non-empty and not JSON, treat as comma-separated list of names
if [[ -n "${PACKAGES:-}" ]]; then
	IFS=',' read -ra names <<< "$PACKAGES"
	for n in "${names[@]}"; do
		n_trimmed="$(echo "$n" | xargs)"
		if [[ -n "$n_trimmed" ]]; then
			install_pkg "$n_trimmed" true latest
		fi
	done
	exit 0
fi

# Fallback: single PACKAGE and VERSION environment variables (older behavior)
if [[ -n "${PACKAGE:-}" ]]; then
	ver="${VERSION:-latest}"
	g="${GLOBAL:-true}"
	install_pkg "$PACKAGE" "$g" "$ver"
	exit 0
fi

echo "No packages specified; nothing to do."
