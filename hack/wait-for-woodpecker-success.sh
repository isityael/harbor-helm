#!/bin/sh
set -eu

sha="${1:?commit SHA is required}"
shift
test "$#" -gt 0 || { echo "at least one Woodpecker status context is required" >&2; exit 2; }

: "${FORGEJO_API_URL:?FORGEJO_API_URL is required}"
: "${FORGEJO_REPOSITORY:?FORGEJO_REPOSITORY is required}"
: "${FORGEJO_TOKEN:?FORGEJO_TOKEN is required}"

max_attempts="${WOODPECKER_GATE_MAX_ATTEMPTS:-240}"
sleep_seconds="${WOODPECKER_GATE_SLEEP_SECONDS:-15}"
attempt=1

while [ "$attempt" -le "$max_attempts" ]; do
  statuses="$(curl --fail --silent --show-error \
    --header "Authorization: token ${FORGEJO_TOKEN}" \
    "${FORGEJO_API_URL}/repos/${FORGEJO_REPOSITORY}/statuses/${sha}?limit=100")"
  waiting=0
  for context in "$@"; do
    state="$(printf '%s' "$statuses" | jq -r --arg context "$context" \
      '[.[] | select(.context == $context)][0].status // "missing"')"
    case "$state" in
      success) echo "$context: success" ;;
      failure|error|killed|cancelled|canceled)
        echo "$context: $state; refusing to create a release tag" >&2
        exit 1
        ;;
      *)
        echo "$context: $state; waiting ($attempt/$max_attempts)"
        waiting=1
        ;;
    esac
  done
  [ "$waiting" -eq 1 ] || exit 0
  [ "$attempt" -lt "$max_attempts" ] || break
  sleep "$sleep_seconds"
  attempt=$((attempt + 1))
done

echo "Woodpecker status gate timed out for $sha" >&2
exit 1
