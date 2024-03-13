#!/usr/bin/env bash

latest_version="$(./.github/scripts/utils/find_latest_keycloak.sh)"

echo "$latest_version"
ls -d "$(pwd)"/keycloak-*

case "$(uname)" in
    Darwin*) sed () { command sed -i '' "$@"; } ;;
    *)       sed () { command sed -i "$@"; } ;;
esac

# Check if the version in the README.md file is different from the latest version
current_version=$(grep -o "docker.io/camunda/keycloak:[0-9]\+" README.md | head -n 1 | cut -d ":" -f 2)
if [ "${current_version}" != "${latest_version}" ]; then
    sed -E "s@docker.io/camunda/keycloak:[0-9]+@docker.io/camunda/keycloak:${latest_version}@g" README.md

    echo "The docker image version in the README.md has been updated from docker.io/camunda/keycloak:${current_version} to docker.io/camunda/keycloak:${latest_version}" >&2
    exit 1
fi
