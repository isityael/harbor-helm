# CLAUDE — Runtime Instructions

This is a **fork of [goharbor/harbor-helm](https://github.com/goharbor/harbor-helm)** maintained by sm-moshi.

## Purpose

Carry unreleased upstream fixes and cherry-picked PRs that upstream maintainers haven't merged.
Published as an OCI Helm chart to `oci://ghcr.io/sm-moshi/charts/harbor`.

## Key rules

- **Rebase on upstream, don't diverge.** All changes should be cherry-picks from upstream PRs
  or minimal fixes that can be upstreamed. Avoid custom features that make rebasing harder.
- **Never modify upstream defaults** unless the change comes from a specific upstream PR.
  Our wrapper chart in the infra repo (`apps/user/harbor/values.yaml`) handles all overrides.
- **Version scheme:** `version` in Chart.yaml tracks our release (e.g. `1.19.0`).
  `appVersion` tracks the Harbor release (e.g. `v2.15.0-rc2`).
- **No secrets or credentials** in this repo. Chart is published via GHA with `GITHUB_TOKEN`.
- **Branch:** `sm-moshi/main` is the primary branch. Upstream `main` is tracked via `upstream` remote.

## Workflow

### Adding a new upstream PR fix
```bash
git fetch upstream pull/<PR>/head:pr-<PR>
git cherry-pick <commit-hash>
# Resolve conflicts, test with:
helm lint .
helm template harbor . -f values.yaml
```

### Rebasing on a new upstream release
```bash
git fetch upstream
git rebase upstream/main
# Drop commits that upstream has merged
# Bump version in Chart.yaml
# Tag and push
```

### Releasing
```bash
git tag v<version>
git push origin v<version>
# GHA workflow packages and pushes to ghcr.io/sm-moshi/charts
```

## Validation
```bash
helm lint .
helm template harbor . -f values.yaml
helm template harbor . --set "expose.type=nodePort,expose.tls.auto.commonName=127.0.0.1"
```

## Cherry-picked PRs (v1.19.0)

| PR | Description |
|----|-------------|
| #2310 | Fix: reuse existing secretKey/TLS certs (fixes ArgoCD drift #2263) |
| #2307 | Default image tag to chart appVersion |
| #2314 | Fix rollingUpdate checks for jobservice/registry |
| #2312 | Fix ArgoCD diff in httproute |
| #2317 | Configurable health probe timeoutSeconds/failureThreshold |
| #2330 | Parametrise gracePeriodTerminationSeconds + core startupProbe |

## Consumer

The infra repo (`sm-moshi/infra`) consumes this chart as an OCI dependency in
`apps/user/harbor/Chart.yaml`. This repo is **not** a submodule.

## Style

- Use British English in all prose.
