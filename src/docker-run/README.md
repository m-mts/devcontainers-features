# docker-run feature

Helper feature to run Docker images inside devcontainers using `docker-outside-of-docker`.
This feature provides a small wrapper (`install.sh`) that accepts a CSV of image names or `docker run`-style parameters and executes them via `docker`.

## Options

- `images` (string) — A comma-separated list of images or run-arguments. Examples are provided in the feature `devcontainer-feature.json` `options.images.proposals` field.

The `images` value can contain:
- Plain image names: `hello-world`, `postgres:13` — these are run as `docker run --rm <image>` by default.
- Option-prefixed entries: `--rm -e POSTGRES_PASSWORD=secret -p 5432:5432 postgres:latest` — the script prefixes these with `docker run` and runs them.
- Full `docker` commands starting with `docker ` will be executed as given.

Environment fallbacks:
- You may pass images via the `IMAGES` environment variable or the legacy `PACKAGES` env var.
- You can also pass a first argument to `install.sh` which will be used as the CSV input.

## Examples

Run the feature script with a CSV of images:

```bash
# Run hello-world and a temporary Postgres container
IMAGES='hello-world,--rm -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 postgres:latest' bash src/docker-run/install.sh
```

Pass images as the first argument:

```bash
bash src/docker-run/install.sh "hello-world,postgres:13"
```

Using a full docker command in proposals (executed as-is):

```bash
IMAGES='docker run --rm alpine:latest echo hi' bash src/docker-run/install.sh
```

## Tests

Two tests are provided under `test/docker-run`:

- `test/docker-run/smoke.sh` — fast smoke test that stubs `docker` and asserts the expected commands are invoked.
- `test/docker-run/integration.sh` — runs `install.sh` inside a disposable container. This test requires Docker to be installed on the host.

Run smoke test:

```bash
./test/docker-run/smoke.sh
```

Run integration test:

```bash
./test/docker-run/integration.sh --images 'hello-world'
```

## Notes

- The script expects `docker` to be available in PATH when actually executing containers.
- The `images` proposals in `devcontainer-feature.json` are examples only; adjust passwords and ports as appropriate for your environment.
- If you want proposals to be full `docker run` commands, update `devcontainer-feature.json` and `install.sh` will run them as given.

