#!/usr/bin/env bash

# Script: get_awssdk_jar_version.sh
# Description: Finds the version of "software.amazon.awssdk" used by a aws jdbc wrapper version
# Usage: get_awssdk_jar_version.sh <aws-jdbc-wrapper-version>


SDK_VERSION="$(curl -s https://raw.githubusercontent.com/awslabs/aws-advanced-jdbc-wrapper/$1/wrapper/build.gradle.kts | grep "software.amazon.awssdk:rds" | awk -F ":" '{print $3}' | awk -F "'" '{print $1}' | head -n 1 | tr -d "\"" | tr -d ")")"

echo "$SDK_VERSION"
