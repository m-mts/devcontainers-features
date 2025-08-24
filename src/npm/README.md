
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
| packages | A JSON array (string) of package objects to install, e.g. '[{"package":"typescript","global":true,"version":"latest"}]'. Alternatively a comma-separated list of package names is supported for simple installs. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/m-mts/devcontainers-features/blob/main/src/npm/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
