#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
script="${repo_root}/.ci/pre-commit/chart-version-bump.sh"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

setup_repo() {
  local workdir="$1"
  local version="${2:-1.19.7}"

  git -C "$workdir" init -q
  git -C "$workdir" config user.email test@example.invalid
  git -C "$workdir" config user.name "Chart Version Test"

  mkdir -p "$workdir/templates"
  cat >"$workdir/Chart.yaml" <<YAML
apiVersion: v1
name: harbor
version: ${version}
appVersion: v2.15.1
YAML
  cat >"$workdir/values.yaml" <<'YAML'
portal:
  image:
    repository: goharbor/harbor-portal
    tag: "v2.15.1"
YAML
  cat >"$workdir/templates/service.yaml" <<'YAML'
apiVersion: v1
kind: Service
metadata:
  name: harbor
YAML

  git -C "$workdir" add Chart.yaml values.yaml templates
  git -C "$workdir" commit -qm "Initial chart"
}

assert_version() {
  local workdir="$1"
  local want="$2"
  local got

  got="$(awk '/^version:/ {print $2}' "$workdir/Chart.yaml")"
  [ "$got" = "$want" ] || fail "expected chart version ${want}, got ${got}"
}

assert_staged() {
  local workdir="$1"
  local path="$2"

  git -C "$workdir" diff --cached --name-only | grep -qx "$path" || fail "expected ${path} to be staged"
}

test_values_change_bumps_chart_version() {
  local workdir="${tmpdir}/values-change"
  mkdir -p "$workdir"
  setup_repo "$workdir"

  sed -i.bak 's/v2.15.1/v2.15.2/' "$workdir/values.yaml"
  rm "$workdir/values.yaml.bak"
  git -C "$workdir" add values.yaml

  (cd "$workdir" && "$script")

  assert_version "$workdir" "1.19.8"
  assert_staged "$workdir" "Chart.yaml"
}

test_template_change_bumps_chart_version() {
  local workdir="${tmpdir}/template-change"
  mkdir -p "$workdir"
  setup_repo "$workdir"

  printf '\n  labels:\n    app: harbor\n' >>"$workdir/templates/service.yaml"
  git -C "$workdir" add templates/service.yaml

  (cd "$workdir" && "$script")

  assert_version "$workdir" "1.19.8"
  assert_staged "$workdir" "Chart.yaml"
}

test_existing_chart_version_change_is_not_bumped_again() {
  local workdir="${tmpdir}/already-bumped"
  mkdir -p "$workdir"
  setup_repo "$workdir"

  sed -i.bak 's/v2.15.1/v2.15.2/' "$workdir/values.yaml"
  rm "$workdir/values.yaml.bak"
  sed -i.bak 's/version: 1.19.7/version: 1.19.9/' "$workdir/Chart.yaml"
  rm "$workdir/Chart.yaml.bak"
  git -C "$workdir" add values.yaml Chart.yaml

  (cd "$workdir" && "$script")

  assert_version "$workdir" "1.19.9"
  assert_staged "$workdir" "Chart.yaml"
}

test_values_change_bumps_chart_version
test_template_change_bumps_chart_version
test_existing_chart_version_change_is_not_bumped_again

echo "chart-version-bump tests passed"
