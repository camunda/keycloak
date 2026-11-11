#!/usr/bin/env bash

# Script: find_latest_keycloak.sh
# Description: Finds the latest version of Keycloak from folders prefixed with "keycloak-" in the current directory.
# Usage: find_latest_keycloak.sh

set -Eeuo pipefail
shopt -s failglob

printf '%s\n' "$(pwd)"/keycloak-* | tail -n 1 | awk -F'[-/]' '{print $(NF-0)}'
