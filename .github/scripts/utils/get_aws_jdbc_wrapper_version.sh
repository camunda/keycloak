#!/usr/bin/env bash

# Script: get_aws_jdbc_wrapper_version.sh
# Description: Finds the aws jdbc wrapper version of the Keycloak version from the pom.xml
# Usage: get_aws_jdbc_wrapper_version.sh <keycloak-version>

# Function to extract the first number from a version string
get_first_number() {
    echo "$1" | cut -d '.' -f1
}

# Function to compare version numbers considering only the first number
version_lt() {
    [ "$(get_first_number "$1")" -lt "$(get_first_number "$2")" ]
}

# Keycloak only started to reference the aws_jdbc_wrapper version starting with v24, defaulting a fixed version of the jdbc driver,
# this check also allow bumping minimal aws_jdbc_wrapper version for critical fixes
if version_lt "$1" "25"; then
    echo "2.3.5" # fix https://github.com/keycloak/keycloak/issues/27290
else
    VERSION="$1"
fi

# Fetch the AWS JDBC wrapper version from the pom.xml file
AWS_JDBC_VERSION="$(curl -s "https://raw.githubusercontent.com/keycloak/keycloak/$VERSION/pom.xml" | awk -F'[><]' '/<aws-jdbc-wrapper.version>/{print $3}')"

echo "$AWS_JDBC_VERSION"
