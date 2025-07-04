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

## 🛠️ Building the Image (Development Only)

> [!NOTE]
> Building a local image is **only for development purposes**.
> In production, the pipeline handles building a multi-architecture image using Docker Buildx.

Navigate to the `keycloak-<version>` directory (e.g. `keycloak-24`) and execute the following commands:

### 1. 📦 Choose your base image

The base image is defined in the `bases.yml` file. You must decide between:

* `hub`: the **open-source** Bitnami Keycloak image (from Docker Hub)
* `prem`: the **Bitnami Premium** version (from Camunda’s private registry)

> [!NOTE]
> The YAML schema is a valid Helm values schema. This choice was made for easier maintenance with Renovate parsing.

### 2. 🔧 Build with `yq`

Use the following command to extract the base image name and digest using [`yq`](https://mikefarah.gitbook.io/yq/) (Go version):

```bash
# Choose 'hub' or 'prem'
BASE_SOURCE="hub"

# Extract base image name and digest
BASE_IMAGE_NAME="$(yq e ".sources.$BASE_SOURCE.image.repository" bases.yml)"
BASE_IMAGE_TAG="$(yq e ".sources.$BASE_SOURCE.image.tag" bases.yml | cut -d@ -f1)"
BASE_IMAGE_DIGEST="$(yq e ".sources.$BASE_SOURCE.image.tag" bases.yml | cut -d@ -f2)"

# Extract Keycloak version from image tag
KEYCLOAK_VERSION="$(echo "$BASE_IMAGE_NAME" | awk -F'[:/-]' '{print $(NF-1)}')"
echo "Using Keycloak version: $KEYCLOAK_VERSION"

# Build the image
docker build \
  --build-arg BASE_IMAGE_NAME="$BASE_IMAGE_NAME" \
  --build-arg BASE_IMAGE_TAG="$BASE_IMAGE_TAG" \
  --build-arg BASE_IMAGE_DIGEST="$BASE_IMAGE_DIGEST" \
  -t "docker.io/camunda/keycloak:$KEYCLOAK_VERSION" .
```

This Dockerfile includes the necessary dependencies and configurations for the **AWS Advanced JDBC Wrapper** and custom Keycloak themes.


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
