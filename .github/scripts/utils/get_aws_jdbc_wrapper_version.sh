#!/usr/bin/env bash

# Script: get_aws_jdbc_wrapper_version.sh
# Description: Finds the AWS JDBC wrapper version of the Keycloak version from the pom.xml, <keycloak-version> must be formatted as major.minor.patch
# Usage: get_aws_jdbc_wrapper_version.sh <keycloak-version>

set -Eeuo pipefail

display_help() {
    echo "Script: get_aws_jdbc_wrapper_version.sh"
    echo "Description: Finds the AWS JDBC wrapper version of the Keycloak version from the pom.xml"
    echo "Usage: get_aws_jdbc_wrapper_version.sh <keycloak-version>"
}

# Check if there is exactly one argument provided
if [[ $# -ne 1 ]]; then
    echo "Error: Incorrect number of arguments."
    display_help
    exit 1
fi

keycloak_version="$1"

# Validate keycloak version format (major.minor.patch)
if ! [[ "$keycloak_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid keycloak version format. It must be in the format of major.minor.patch."
    display_help
    exit 1
fi

# Function to extract the first number from a version string
get_major_version() {
    echo "$keycloak_version" | cut -d '.' -f1
}

# Keycloak only started to reference the aws_jdbc_wrapper version starting with v24, defaulting a fixed version of the jdbc driver,
# this check also allow bumping minimal aws_jdbc_wrapper version for critical fixes
if [[ "$(get_major_version "$keycloak_version")" -lt "25" ]] ; then
    echo "2.3.5" # fix https://github.com/keycloak/keycloak/issues/27290
    exit 0
fi

# Fetch the AWS JDBC wrapper version from the pom.xml file
AWS_JDBC_VERSION="$(curl -s "https://raw.githubusercontent.com/keycloak/keycloak/$keycloak_version/pom.xml" | awk -F'[><]' '/<aws-jdbc-wrapper.version>/{print $3}')"

if [[ -z "$AWS_JDBC_VERSION" ]]; then
    echo "Error: Failed to retrieve AWS JDBC version." >&2
    exit 1
fi

echo "$AWS_JDBC_VERSION"
