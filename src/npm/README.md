# npm feature

Installs one or more npm packages inside the devcontainer.

This feature accepts a `packages` option (see below) and installs each entry with
npm, supporting per-package version and global/local install semantics. The
feature also keeps a backwards-compatible fallback to the older `PACKAGE`/
`VERSION` environment variables.

## Usage

Enable the feature in your `devcontainer.json`:

```jsonc
"features": {
  "ghcr.io/devcontainers-community/features/npm": {
    "packages": "[{\"package\":\"typescript\",\"global\":true,\"version\":\"latest\"}]"
  }
}
```

## Options

- `packages` (string) — A JSON string representing an array of package objects, or a comma-separated list of package names.

Each package object has the shape:

```
{ "package": "name", "global": true|false, "version": "1.2.3" }
```

Examples:

- JSON array (preferred for per-package settings):

```jsonc
"packages": "[
  {\"package\":\"typescript\",\"global\":true,\"version\":\"latest\"},
  {\"package\":\"nodemon\",\"global\":false,\"version\":\"2.0.0\"}
]"
```

- Comma-separated list (simple, installs each as `global latest`):

```jsonc
"packages": "typescript,nodemon"
```

- Fallback (older behavior): set `PACKAGE`, `VERSION`, and optional `GLOBAL` env vars.

## Testing

Put test scripts for this feature under the local `test/` folder (next to
`install.sh` and `README.md`). Example test names:

- `test/npm/smoke.sh` — quick smoke test that runs `install.sh` with a stubbed `npm`/`node` environment and verifies expected commands.
- `test/npm/integration.sh` — (optional) a script that runs inside a disposable container and performs real installs.

Example: run a smoke test locally that uses stubs for `node` and `npm` to validate behavior without making network changes.

```bash
# from repository root
# PATH=/tmp/npm-stub:$PATH PACKAGES='[{"package":"typescript","global":true,"version":"latest"}]' bash src/npm/install.sh
```

Create the test scripts you want under `src/npm/test/` or `test/` and reference them in CI.

## Notes
- `version` defaults to `latest` when omitted.
- `global` defaults to `true` when omitted in a package object.
- Scoped packages (e.g., `@scope/pkg`) and version tags are supported.

