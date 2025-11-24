# Developer's Guide

## 🛠️ Building the Image (Development Only)

> [!NOTE]
> Building a local image is **only for development purposes**.
> In production, the pipeline handles building a multi-architecture image using Docker Buildx.

Navigate to the `keycloak-<version>` directory (e.g. `keycloak-24`) and execute the following commands:

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

### 1. 📦 Choose your base image

The base image is defined in the `bases.yml` file. You must decide between:

* `quay`: the **official** Keycloak image (from Quay.io) - ✅ **Recommended and actively maintained**
* `hub`: the **open-source** Bitnami Legacy Keycloak image (from `docker.io/bitnamilegacy`) - ⚠️ **No longer updated**
> [!NOTE]
> The YAML schema is a valid Helm values schema. This choice was made for easier maintenance with Renovate parsing.

### 2. 🔧 Build with `yq`

Use the following command to extract the base image name and digest using [`yq`](https://mikefarah.gitbook.io/yq/) (Go version):

#### For Bitnami images (hub/prem)

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
  -t "docker.io/camunda/keycloak:bitnami-$KEYCLOAK_VERSION" .
```

#### For Quay images

```bash
# Use the 'quay' source
BASE_SOURCE="quay"

# Extract base image name and digest
BASE_IMAGE_NAME="$(yq e ".sources.$BASE_SOURCE.image.repository" bases.yml)"
BASE_IMAGE_TAG="$(yq e ".sources.$BASE_SOURCE.image.tag" bases.yml | cut -d@ -f1)"
BASE_IMAGE_DIGEST="$(yq e ".sources.$BASE_SOURCE.image.tag" bases.yml | cut -d@ -f2)"

# For Quay images, the tag is already the semver
KEYCLOAK_VERSION="$BASE_IMAGE_TAG"
echo "Using Keycloak version: $KEYCLOAK_VERSION"

# Build standard runtime-configurable image
docker build \
  --build-arg BASE_IMAGE_NAME="$BASE_IMAGE_NAME" \
  --build-arg BASE_IMAGE_TAG="$BASE_IMAGE_TAG" \
  --build-arg BASE_IMAGE_DIGEST="$BASE_IMAGE_DIGEST" \
  --build-arg BUILD_OPTIMIZED=false \
  -f Dockerfile.quay \
  -t "docker.io/camunda/keycloak:quay-$KEYCLOAK_VERSION" .

# Build optimized image (recommended for production)
docker build \
  --build-arg BASE_IMAGE_NAME="$BASE_IMAGE_NAME" \
  --build-arg BASE_IMAGE_TAG="$BASE_IMAGE_TAG" \
  --build-arg BASE_IMAGE_DIGEST="$BASE_IMAGE_DIGEST" \
  --build-arg BUILD_OPTIMIZED=true \
  -f Dockerfile.quay \
  -t "docker.io/camunda/keycloak:quay-optimized-$KEYCLOAK_VERSION" .
```

#### Quay Image Build Modes

Quay-based images support two build modes controlled by the `BUILD_OPTIMIZED` build argument:

**Standard Mode (`BUILD_OPTIMIZED=false`)**
- Full runtime configuration flexibility
- All Keycloak options configurable via environment variables
- Ideal for development and custom configurations
- Produces `quay-<version>` tagged images

**Optimized Mode (`BUILD_OPTIMIZED=true`, default)**
- Pre-built configuration using `kc.sh build` for faster startup
- AWS JDBC wrapper, database settings, health/metrics baked into image
- Reduced runtime environment variables needed
- Required for Keycloak Operator deployments
- Produces `quay-optimized-<version>` tagged images

The optimized build runs the following command during image construction:
```bash
/opt/keycloak/bin/kc.sh build \
    --db=postgres \
    --db-driver=software.amazon.jdbc.Driver \
    --features=docker \
    --health-enabled=true \
    --metrics-enabled=true \
    --transaction-xa-enabled=false
```

**Why AWS JDBC Driver as Default for Optimized Images?**

In optimized images, we use the AWS Advanced JDBC Wrapper (`software.amazon.jdbc.Driver`) as the default database driver for the following reasons:

- **Single Driver Limitation**: Keycloak's optimized build process only allows one database driver to be pre-configured at build time
- **Backward Compatibility**: The AWS JDBC wrapper is fully backward-compatible with standard PostgreSQL connections
- **Versatility**: This choice enables both scenarios:
  - Standard PostgreSQL: Works transparently without AWS-specific features
  - AWS Aurora with IRSA: Enables advanced features like IAM authentication and failover
- **Production Focus**: Optimized images target production deployments where AWS integration is common

When using standard PostgreSQL (non-AWS), the AWS wrapper behaves identically to the native PostgreSQL driver, ensuring seamless operation across all deployment scenarios.

For more information, see the [official Keycloak documentation on optimized builds](https://www.keycloak.org/server/configuration#_optimize_the_keycloak_startup).

Both Dockerfiles include the necessary dependencies and configurations for the **AWS Advanced JDBC Wrapper** and custom Keycloak themes.


## Setting up a New Version of Keycloak


When adding a new version of Keycloak, follow these steps:

1. **Create a Directory:**
   - Create a directory for the new version at the root of this repository.
   - Name the directory using the pattern: `keycloak-<major_version>`, where `<major_version>` represents the major release version.

2. **Major Version Considerations:**
   - Note that Keycloak supports only one version of Postgres per major release.
   - Find the version in the `pom.xml` file of the project. You can locate it [here](https://github.com/keycloak/keycloak/blob/archive/release/24.0/pom.xml).
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
     - **Bitnami-based public images (`docker.io/camunda/keycloak`)**:
       - With prefix (new naming):
         - `camunda/keycloak:bitnami-24` (mutable - triggered by any change in the base image of Keycloak)
         - `camunda/keycloak:bitnami-24.0.1` (mutable - triggered by any change part of the base image of Keycloak)
         - `camunda/keycloak:bitnami-24.0.1-1` (mutable - triggered by any change not part of the base image of Keycloak)
         - `camunda/keycloak:bitnami-24.0.1-1-${date in yyyy-mm-dd-xxx format}` (immutable, recommended for production usage)
         - `camunda/keycloak:bitnami-latest` (latest bitnami version)
       - Without prefix (backward compatibility):
         - `camunda/keycloak:24` (mutable - backward compatible)
         - `camunda/keycloak:24.0.1` (mutable - backward compatible)
         - `camunda/keycloak:24.0.1-1` (mutable - backward compatible)
         - `camunda/keycloak:24.0.1-1-${date in yyyy-mm-dd-xxx format}` (immutable - backward compatible)
         - `camunda/keycloak:latest-bitnami` (latest bitnami version - backward compatible)
     - **Bitnami Enterprise images (`registry.camunda.cloud/keycloak-ee/keycloak`)**:
       - With prefix (new naming):
         - `keycloak-ee/keycloak:bitnami-ee-24` (mutable - triggered by any change in the base image of Keycloak)
         - `keycloak-ee/keycloak:bitnami-ee-24.0.1` (mutable - triggered by any change part of the base image of Keycloak)
         - `keycloak-ee/keycloak:bitnami-ee-24.0.1-1` (mutable - triggered by any change not part of the base image of Keycloak)
         - `keycloak-ee/keycloak:bitnami-ee-24.0.1-1-${date in yyyy-mm-dd-xxx format}` (immutable, recommended for production usage)
         - `keycloak-ee/keycloak:bitnami-ee-latest` (latest bitnami enterprise version)
       - Without prefix (backward compatibility):
         - `keycloak-ee/keycloak:24` (mutable - backward compatible)
         - `keycloak-ee/keycloak:24.0.1` (mutable - backward compatible)
         - `keycloak-ee/keycloak:24.0.1-1` (mutable - backward compatible)
         - `keycloak-ee/keycloak:24.0.1-1-${date in yyyy-mm-dd-xxx format}` (immutable - backward compatible)
         - `keycloak-ee/keycloak:latest` (latest bitnami enterprise version - no conflict with quay)
     - **Quay-based public images (`docker.io/camunda/keycloak`)**:
       - `camunda/keycloak:latest` (latest standard non-optimized Quay-based image)
       - `camunda/keycloak:quay-24` (standard runtime-configurable image, mutable)
       - `camunda/keycloak:quay-24.0.5-1` (standard runtime-configurable image, mutable)
       - `camunda/keycloak:quay-24.0.5-1-${date in yyyy-mm-dd-xxx format}` (standard image, immutable)
       - `camunda/keycloak:quay-24.0.5` (standard image, mutable semver tag)
       - `camunda/keycloak:quay-latest` (latest standard non-optimized Quay-based image)
       - `camunda/keycloak:quay-optimized-24` (optimized image, mutable)
       - `camunda/keycloak:quay-optimized-24.0.5-1` (optimized image, mutable)
       - `camunda/keycloak:quay-optimized-24.0.5-1-${date in yyyy-mm-dd-xxx format}` (optimized image, immutable, **recommended for production**)
       - `camunda/keycloak:quay-optimized-24.0.5` (optimized image, mutable semver tag)
       - `camunda/keycloak:quay-optimized-latest` (latest optimized Quay-based image)

Following these steps ensures a smooth integration of new Keycloak versions, consistent testing across the development environment, and easy access to the latest version. Happy coding!
