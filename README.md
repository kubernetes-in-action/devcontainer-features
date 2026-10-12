# devcontainer-features

Dev Container Features for: [`kind`](src/kind/) and [`kustomize`](src/kustomize/). Built for the
*Kubernetes in Production* companion code (`kubernetes-in-production`).

## Features

| Feature | Installs | Options |
|---|---|---|
| [`kind`](src/kind/) | the `kind` CLI | `version` (default `latest`) |
| [`kustomize`](src/kustomize/) | the `kustomize` CLI | `version` (default `latest`) |

## Using them

Reference by tag during development, or pin to the exact digest created by a release:
```json
"features": {
  "ghcr.io/kubernetes-in-action/devcontainer-features/kind:1": {
    "version": "v0.33.0"
  },
  "ghcr.io/kubernetes-in-action/devcontainer-features/kustomize:1": {
    "version": "v5.8.3"
  }
}
```

```json
"features": {
  "ghcr.io/kubernetes-in-action/devcontainer-features/kind@sha256:<digest>": {},
  "ghcr.io/kubernetes-in-action/devcontainer-features/kustomize@sha256:<digest>": {}
}
```

## How a release works

1. A push to `main` touching `src/**` runs [`release.yaml`](.github/workflows/release.yaml).
2. [`devcontainers/action`](https://github.com/devcontainers/action) packages each
   feature folder as an OCI artifact and pushes it to `ghcr.io/kubernetes-in-action/devcontainer-features/<id>`,
   tagged by semver (`1`, `1.0`, `1.0.0`) from each `devcontainer-feature.json`.
3. The workflow resolves the digest `devcontainers/action` just pushed (via `oras`)
   and signs it **keylessly** with `cosign`, using the workflow's own GitHub OIDC
   token.  The signature is itself pushed to the registry, verifiable with:

   ```
   cosign verify \
     --certificate-identity-regexp '^https://github.com/kubernetes-in-action/devcontainer-features/' \
     --certificate-oidc-issuer https://token.actions.githubusercontent.com \
     ghcr.io/kubernetes-in-action/devcontainer-features/kind@sha256:<digest>
   ```

## Testing locally

```
npm install -g @devcontainers/cli
devcontainer features test -f kind -i mcr.microsoft.com/devcontainers/base:ubuntu .
devcontainer features test -f kustomize -i mcr.microsoft.com/devcontainers/base:ubuntu .
```

## Bumping a tool version

1. Edit the version `default/proposals` in the feature's `devcontainer-feature.json`
   if you want the floating-tag default to move.
2. Bump the feature's own `version` field (semver) so the publish step cuts a new tag.
3. Push to `main`. CI tests, publishes, and signs automatically.
4. In each consumer repo, update the pinned `@sha256:...` reference after verifying
   the new signature.
