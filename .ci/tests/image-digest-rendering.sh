#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
rendered="$(mktemp)"
trap 'rm -f "${rendered}"' EXIT

digest="sha256:1111111111111111111111111111111111111111111111111111111111111111"
image_paths=(
  nginx.image
  portal.image
  core.image
  jobservice.image
  registry.registry.image
  registry.controller.image
  trivy.image
  database.internal.image
  redis.internal.image
  exporter.image
)

helm_args=(
  template harbor "${repo_root}"
  --set expose.type=nodePort
  --set expose.tls.auto.commonName=127.0.0.1
  --set metrics.enabled=true
  --set enableMigrateHelmHook=true
)
for image_path in "${image_paths[@]}"; do
  helm_args+=(--set-string "${image_path}.digest=${digest}")
done

helm "${helm_args[@]}" > "${rendered}"

if grep -En 'image: .*@sha256:[[:xdigit:]]{64}@sha256:[[:xdigit:]]{64}$' "${rendered}"; then
  echo "a Harbor image reference must contain at most one immutable digest" >&2
  exit 1
fi

digest_refs="$(grep -Ec "image: .*@${digest}$" "${rendered}" || true)"
[[ "${digest_refs}" -eq 12 ]] || {
  echo "expected all 12 Harbor container references to render the configured digest; got ${digest_refs}" >&2
  exit 1
}

if grep -RFn 'image: {{ .Values' "${repo_root}/templates"; then
  echo "all first-party container references must use the shared image helper" >&2
  exit 1
fi

echo "Harbor image digest rendering contract passed"
