#!/usr/bin/env bash
set -euo pipefail
shopt -s nocasematch

echo "Installing npm packages from PACKAGES..."

# PACKAGES supported formats:
# 1) JSON string (array) of objects: [ { "package": "name", "global": true, "version": "latest" }, ... ]
# 2) Comma-separated list of simple names: "npm,yarn,typescript"
# 3) Comma-separated list of npm-style args per item: "-g npm@latest, -g yarn@latest, typescript@5"
#    Each item is split by whitespace into args and passed directly to 'npm install'.

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

clean_outer_quotes() {
	local s="$1"
	# Trim leading/trailing whitespace
	s="$(printf '%s' "$s" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	# Remove surrounding double quotes if present
	if [[ "$s" == \"*\" && "$s" == *\" ]]; then
		s="${s:1:$((${#s}-2))}"
	fi
	printf '%s' "$s"
}

# Try to parse PACKAGES as JSON array if it appears to be JSON after cleaning
if [[ -n "${PACKAGES:-}" ]]; then
	p_clean="$(clean_outer_quotes "$PACKAGES")"
	p_nospace="${p_clean//[[:space:]]/}"
	if [[ "$p_nospace" == \[* ]]; then
		# Use node to parse and emit lines: package|global|version
		mapfile -t entries < <(node -e '
const input = process.argv[1] || "";
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
' -- "$p_clean") || true

		if [[ ${#entries[@]} -gt 0 ]]; then
			for e in "${entries[@]}"; do
				IFS='|' read -r pkg g v <<< "$e"
				install_pkg "$pkg" "$g" "$v"
			done
			exit 0
		fi
		echo "PACKAGES was JSON but produced no valid entries, falling back..."
	fi
fi

# If PACKAGES is non-empty and not JSON, treat as comma-separated list of names or npm args
if [[ -n "${PACKAGES:-}" ]]; then
	IFS=',' read -ra names <<< "$PACKAGES"
	for n in "${names[@]}"; do
		n_trimmed="$(printf '%s' "$n" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
		if [[ -z "$n_trimmed" ]]; then
			continue
		fi

		# If the item looks like npm args (starts with -) or contains an @ (version) or a slash (scoped pkg)
		if [[ "$n_trimmed" == -'*' || "$n_trimmed" == *"@"* || "$n_trimmed" == *"/"* || "$n_trimmed" == *" "* ]]; then
			# Split into args and pass directly to npm install
			read -r -a args <<< "$n_trimmed"
			echo "npm install ${args[*]}"
			npm install "${args[@]}"
		else
			# simple package name -> install globally at latest
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
