#!/usr/bin/env bash

# Script: get_aws_jdbc_wrapper_version.sh
# Description: Finds the aws jdbc wrapper version of the Keycloak version from the pom.xml
# Usage: get_aws_jdbc_wrapper_version.sh <keycloak-version>

set -e

display_help() {
    echo "Script: get_aws_jdbc_wrapper_version.sh"
    echo "Description: Finds the AWS JDBC wrapper version of the Keycloak version from the pom.xml"
    echo "Usage: get_aws_jdbc_wrapper_version.sh <keycloak-version>"
}

check_arguments() {

    if [ $# -ne 1 ]; then
        echo "Error: Incorrect number of arguments."
        display_help
        exit 1
    fi
}

check_arguments "$@"

# Function to extract the first number from a version string
get_major_version() {
    echo "$1" | cut -d '.' -f1
}

# Keycloak only started to reference the aws_jdbc_wrapper version starting with v24, defaulting a fixed version of the jdbc driver,
# this check also allow bumping minimal aws_jdbc_wrapper version for critical fixes
if [[ "$(get_first_number "$1")" -lt "25" ]] ; then
    echo "2.3.5" # fix https://github.com/keycloak/keycloak/issues/27290
    exit 0
else
    VERSION="$1"
fi

# Fetch the AWS JDBC wrapper version from the pom.xml file
AWS_JDBC_VERSION="$(curl -s "https://raw.githubusercontent.com/keycloak/keycloak/$VERSION/pom.xml" | awk -F'[><]' '/<aws-jdbc-wrapper.version>/{print $3}')"

echo "$AWS_JDBC_VERSION"
