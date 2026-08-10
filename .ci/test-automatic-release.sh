#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
workflow="${repo_root}/.forgejo/workflows/release-tag.yaml"

test -f "${workflow}"
grep -Fq 'branches: [isityael/main]' "${workflow}"
grep -Fq 'Chart.yaml' "${workflow}"
grep -Fq 'templates/**' "${workflow}"
grep -Fq '${{ github.server_url }}/api/v1' "${workflow}"
grep -Fq '${{ github.token }}' "${workflow}"
grep -Fq 'refs/tags/v${CHART_VERSION}' "${workflow}"

printf 'automatic Harbor chart release contract passed\n'
