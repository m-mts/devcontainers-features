
# docker-run (docker-run)

Helper feature to run Docker images inside devcontainers using docker-outside-of-docker. Provides a simple wrapper and example package names to pass to 'docker run'.

## Example Usage

```json
"features": {
    "ghcr.io/m-mts/devcontainers-features/docker-run:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| images | A comma-separated list of Docker image names to suggest for 'docker run' (e.g., 'hello-world'). You can also include common runtime params/options when suggesting examples, for example: '-it', '--rm', '-p 8080:80'. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/m-mts/devcontainers-features/blob/main/src/docker-run/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
