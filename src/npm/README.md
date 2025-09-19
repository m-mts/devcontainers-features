
# npm (npm)

Installs one or more npm packages.

## Example Usage

```json
"features": {
    "ghcr.io/m-mts/devcontainers-features/npm:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| packages | Supported formats:
  1) JSON array (string) of package objects, e.g. '[{"package":"typescript","global":true,"version":"latest"}]'
  2) Comma-separated list of package names, e.g. 'npm,yarn,typescript'
  3) Comma-separated list of npm-style args per item, e.g. '-g npm@latest, -g yarn@latest, -g typescript@latest' (each item is passed to 'npm install') | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/m-mts/devcontainers-features/blob/main/src/npm/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
