#!/usr/bin/env bash

# Script: apply_bases_override.sh
# Description: Replaces keycloak-<major>/bases.yml with the YAML given in BASES_OVERRIDE, for an
#              on-demand build of a specific base image. The override is validated first: only the
#              known sources (hub, prem, quay) are accepted, each with a plain repository and a
#              digest-pinned tag. On success it prints the build matrix (JSON) for the overridden
#              sources. On failure nothing is written.
# Usage: BASES_OVERRIDE='<yaml>' apply_bases_override.sh <major>

set -Eeuo pipefail

major="${1:-}"
override="${BASES_OVERRIDE:-}"

die() { echo "::error::$*" >&2; exit 1; }

[[ "$major" =~ ^[0-9]+$ ]] || die "keycloak_major must be a number, got: '${major}'"
target="keycloak-${major}/bases.yml"
[[ -f "$target" ]] || die "no ${target} in this repository"
[[ -n "$override" ]] || die "bases_override is empty"

parsed="$(mktemp)"
trap 'rm -f "$parsed"' EXIT
printf '%s\n' "$override" | yq e -P '.' - > "$parsed" 2>/dev/null || die "bases_override is not valid YAML"

sources="$(yq e '.sources | keys | .[]' "$parsed" 2>/dev/null)" || die "bases_override has no .sources map"
[[ -n "$sources" ]] || die "bases_override has no source"

matrix=()
while IFS= read -r source; do
    case "$source" in
        hub | prem) matrix+=("${major}-${source}") ;;
        quay) matrix+=("${major}-quay" "${major}-quay-optimized") ;;
        *) die "unknown source '${source}', expected hub, prem or quay" ;;
    esac
    repository="$(yq e ".sources.${source}.image.repository" "$parsed")"
    tag="$(yq e ".sources.${source}.image.tag" "$parsed")"
    [[ "$repository" =~ ^[a-z0-9][a-z0-9./_-]*$ ]] || die "invalid repository for ${source}: '${repository}'"
    [[ "$tag" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*@sha256:[a-f0-9]{64}$ ]] || die "tag for ${source} must be '<tag>@sha256:<digest>', got: '${tag}'"
done <<< "$sources"

cp "$parsed" "$target"
printf '%s\n' "${matrix[@]}" | jq -R -s -c 'split("\n")[:-1]'
