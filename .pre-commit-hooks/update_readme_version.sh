#!/usr/bin/env bash

latest_version="$(./.github/scripts/utils/find_latest_keycloak.sh)"

case "$(uname)" in
    Darwin*) sed_universal () { command sed -i '' "$@"; } ;;
    *)       sed_universal () { command sed -i "$@"; } ;;
esac

# Check if any version in the README.md file is different from the latest version
# Look for patterns like: bitnami-26, quay-26, :26 (legacy), etc.

# Extract current versions from different patterns in README
current_bitnami_version=$(grep -o "docker.io/camunda/keycloak:bitnami-[0-9]\+" README.md | head -n 1 | cut -d "-" -f 2)
current_quay_version=$(grep -o "docker.io/camunda/keycloak:quay-[0-9]\+" README.md | head -n 1 | cut -d "-" -f 2)
current_legacy_version=$(grep -o "docker.io/camunda/keycloak:[0-9]\+" README.md | head -n 1 | cut -d ":" -f 2)

# Check if any version needs updating
version_updated=false

# Update bitnami-prefixed versions
if [[ -n "${current_bitnami_version}" && "${current_bitnami_version}" != "${latest_version}" ]]; then
    sed_universal -E "s@docker.io/camunda/keycloak:bitnami-[0-9]+@docker.io/camunda/keycloak:bitnami-${latest_version}@g" README.md
    echo "Updated Bitnami image version from bitnami-${current_bitnami_version} to bitnami-${latest_version}" >&2
    version_updated=true
fi

# Update quay-prefixed versions
if [[ -n "${current_quay_version}" && "${current_quay_version}" != "${latest_version}" ]]; then
    sed_universal -E "s@docker.io/camunda/keycloak:quay-[0-9]+@docker.io/camunda/keycloak:quay-${latest_version}@g" README.md
    echo "Updated Quay image version from quay-${current_quay_version} to quay-${latest_version}" >&2
    version_updated=true
fi

# Exit with code 1 if any version was updated (to indicate changes were made)
if [[ "${version_updated}" == "true" ]]; then
    echo "README.md has been updated to use Keycloak version ${latest_version}" >&2
    exit 1
fi

echo "All image versions in README.md are already up to date (${latest_version})" >&2
