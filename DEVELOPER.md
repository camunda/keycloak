# Developer's Guide

Welcome to the development reference for Keycloak by Camunda! This document provides guidance on setting up a basic testing environment, running unit tests, and testing changes locally.

## Requirements

To gather all specifics versions of this project, we use:
- [asdf](https://asdf-vm.com/) version manager (see [installation](https://asdf-vm.com/guide/getting-started.html)).
- [just](https://github.com/casey/just) as a command runner
  - install it using asdf: `asdf plugin add just && asdf install just`

Then we will install all the tooling listed in the `.tool-versions` of this root project using just:
```bash
just install-tooling

# list available recipes
just --list
```

## Building the Image (Development Only)

Building a local image is for development purposes only.
In production, the pipeline will handle this and build a multi-architecture image using Docker Buildx.

Navigate to the `keycloak-<version>` (e.g. `keycloak-24`) directory and execute the following commands:

```bash
# retrieve the aws jdbc wrapper version from the referenced keycloak version
keycloak_full_version="$(grep "ARG BASE_IMAGE_NAME=.*$1" ./Dockerfile | awk -F'[:=]' '{print $NF}' | tr -d '"' | awk -F'[:/-]' '{print $1}')"
echo "keycloak_full_version=$keycloak_full_version"

aws_jdbc_wrapper_version="$(../.github/scripts/utils/get_aws_jdbc_wrapper_version.sh $keycloak_full_version)"
echo "aws_jdbc_wrapper_version=$aws_jdbc_wrapper_version"

docker build . -t "docker.io/camunda/keycloak:$keycloak_full_version" --build-arg "AWS_JDBC_WRAPPER_VERSION=$aws_jdbc_wrapper_version"
```

This Dockerfile includes the necessary dependencies and configurations for AWS Advanced JDBC Wrapper.

## Setting up a New Version of Keycloak


When adding a new version of Keycloak, follow these steps:

1. **Create a Directory:**
   - Create a directory for the new version at the root of this repository.
   - Name the directory using the pattern: `keycloak-<major_version>`, where `<major_version>` represents the major release version.

2. **Major Version Considerations:**
   - Note that Keycloak supports only one version of Postgres per major release.
   - Find the version in the `pom.xml` file of the project. You can locate it [here](https://github.com/keycloak/keycloak/blob/release/24.0/pom.xml).
   - The pipeline of tests will automatically fetch this file and use the referenced version. For example: `<postgresql.version>15</postgresql.version>` indicates the target test version.
   - Use this version locally for testing.

3. **Release Tagging and Versioning:**
   - Use GitHub releases to trigger the release process.
   - When creating a new release, tag it with a suffix consisting of the date and an incremental number (in case of multiple builds on the same day), e.g., `2024-03-06-001`.
   - Two ways to trigger a release:
     - For all versions at once (e.g., UBI patch): Tag with the format `yyyy-mm-dd-xxx`.
     - For a specific Keycloak version: Tag with the format `keycloak-24-yyyy-mm-dd-xxx` (24 is the major Keycloak version).

4. **Final Image Tags:**
   - The final image will have the following tags:
     - `camunda/keycloak:24` (mutable - triggered by any change in the base image of Keycloak)
     - `camunda/keycloak:24.0.1` (mutable - triggered by any change part of the base image of Keycloak)
     - `camunda/keycloak:24.0.1-1` (mutable - triggered by any change not part of the base image of Keycloak)
     - `camunda/keycloak:24.0.1-1-${date in yyyy-mm-dd-xxx format}` (immutable, recommended for production usage)

Following these steps ensures a smooth integration of new Keycloak versions, consistent testing across the development environment, and easy access to the latest version. Happy coding!
