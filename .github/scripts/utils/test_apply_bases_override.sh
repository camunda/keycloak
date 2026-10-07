#!/usr/bin/env bash

# Script: test_apply_bases_override.sh
# Description: Self-check for apply_bases_override.sh. Runs it in a scratch copy of the repository folders.
# Usage: .github/scripts/utils/test_apply_bases_override.sh

set -Eeuo pipefail

script="$(cd "$(dirname "$0")" && pwd)/apply_bases_override.sh"
repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"
digest="sha256:$(printf 'a%.0s' {1..64})"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "$repo_root"/keycloak-* "$work"/
cd "$work"

fail() { echo "FAIL: $*" >&2; exit 1; }

# happy path: prem only -> prem matrix, bases.yml replaced
out="$(BASES_OVERRIDE="{sources: {prem: {image: {repository: registry.camunda.cloud/vendor-ee/keycloak, tag: 26.1.0-debian-12-r0@${digest}}}}}" \
    "$script" 26)"
[[ "$out" == '["26-prem"]' ]] || fail "prem matrix, got: $out"
[[ "$(yq e '.sources.prem.image.tag' keycloak-26/bases.yml)" == "26.1.0-debian-12-r0@${digest}" ]] || fail "prem tag not written"
[[ "$(yq e '.sources.quay' keycloak-26/bases.yml)" == "null" ]] || fail "quay should be dropped"

# happy path: quay expands to both quay variants
out="$(BASES_OVERRIDE="{sources: {quay: {image: {repository: quay.io/keycloak/keycloak, tag: 26.1.0@${digest}}}}}" "$script" 26)"
[[ "$out" == '["26-quay","26-quay-optimized"]' ]] || fail "quay matrix, got: $out"

# rejections: each must exit non-zero and leave bases.yml untouched
cp -R "$repo_root"/keycloak-26/bases.yml keycloak-26/bases.yml
reject() {
    local major="$1" override="$2"
    if BASES_OVERRIDE="$override" "$script" "$major" >/dev/null 2>&1; then fail "accepted: major=$major override=$override"; fi
    cmp -s "$repo_root/keycloak-26/bases.yml" keycloak-26/bases.yml || fail "bases.yml modified by rejected input: $override"
}
reject 26 ''
reject 26 'not: [valid'
reject 26 '{sources: {}}'
reject 26 "{sources: {prem: {image: {repository: registry.camunda.cloud/vendor-ee/keycloak, tag: 26.1.0-debian-12-r0}}}}"
reject 26 "{sources: {evil: {image: {repository: x, tag: 1@${digest}}}}}"
reject 26 "{sources: {prem: {image: {repository: 'x;rm -rf /', tag: 1@${digest}}}}}"
reject 26 "{sources: {prem: {image: {repository: registry.camunda.cloud/vendor-ee/keycloak, tag: '26.1.0\$(id)@${digest}'}}}}"
reject 99 "{sources: {prem: {image: {repository: registry.camunda.cloud/vendor-ee/keycloak, tag: 26.1.0-debian-12-r0@${digest}}}}}"
reject '../26' "{sources: {prem: {image: {repository: registry.camunda.cloud/vendor-ee/keycloak, tag: 26.1.0-debian-12-r0@${digest}}}}}"

echo "OK"
