# Camunda Keycloak Container Image

[![build-images](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![build-images](https://github.com/camunda/keycloak/actions/workflows/build-images.yml/badge.svg?branch=main)](https://github.com/camunda/keycloak/actions/workflows/build-images.yml)
[![Docker image](https://img.shields.io/badge/docker.io%2Fcamunda%2Fkeycloak-e4f0fb?logo=docker&label=docker%20amd64,arm64)](https://hub.docker.com/r/camunda/keycloak/tags)
[![Docker image Quay](https://img.shields.io/badge/docker.io%2Fcamunda%2Fkeycloak:quay--*-e4f0fb?logo=docker&label=docker%20amd64,arm64)](https://hub.docker.com/r/camunda/keycloak/tags)
[![Licence](https://img.shields.io/github/license/camunda/keycloak)](https://github.com/camunda/keycloak/blob/main/LICENSE)

This Docker image provides a generic Keycloak setup based on [bitnami/keycloak](https://hub.docker.com/r/bitnami/keycloak) or the [official Keycloak image from Quay.io](https://quay.io/repository/keycloak/keycloak). It also includes:
* an optional AWS wrapper, allowing for the use of AWS Identity and Access Management (IAM) Roles for Service Accounts (IRSA) for database authentication.
* an optional [Camunda Identity](https://docs.camunda.io/docs/self-managed/identity/what-is-identity/) login theme

## Image Variants

This repository provides three main image variants:

> **⚠️ Important Note about Bitnami Images**
> Due to [Bitnami's catalog changes](https://github.com/bitnami/containers/issues/83267), starting August 28th, 2025, new Bitnami container images are no longer published to Docker Hub. This repository now consumes images from the `docker.io/bitnamilegacy` repository for continued support.

Users should consider migrating to **Quay-based images** which are actively maintained and recommended for production use.


### 🦆 Quay-based Images (`docker.io/camunda/keycloak:quay-*` and `latest`) **[Recommended]**
Based on the [official Keycloak image from Quay.io](https://quay.io/repository/keycloak/keycloak), these images follow the official Keycloak configuration patterns and are ideal for users who prefer the upstream container conventions. These images use the `quay-` prefix in their tags, and the `latest` tag points to the most recent Quay-based version. They are publicly available on Docker Hub.

**✅ Recommended**: These images are actively maintained and recommended for production use.

#### 🚀 Optimized Images (`docker.io/camunda/keycloak:quay-optimized-*`)
Pre-built configuration variant of Quay-based images with optimized startup times and Camunda-compatible settings:
- **Faster startup**: Configuration is baked into the image during build time
- **Camunda-compatible**: Pre-configured with `/auth` base path for seamless Camunda integration
- **Production-ready**: Includes AWS JDBC wrapper, health/metrics endpoints, and XA transactions disabled
- **Reduced configuration**: Fewer runtime environment variables needed

### 🐳 Bitnami-based Images (`docker.io/camunda/keycloak:bitnami-*`)
Based on the [Bitnami Legacy Keycloak image](https://hub.docker.com/r/bitnamilegacy/keycloak), these images use Bitnami's environment variable conventions and are well-suited for users already familiar with Bitnami's ecosystem. They use the `bitnami-` prefix in their tags and are publicly available on Docker Hub. For backward compatibility, these images are also available without the prefix.

**Note**: These images are based on `bitnamilegacy` repository and receive no further updates from Bitnami. Consider migrating to Quay-based images for production use.

### 🏢 Bitnami Enterprise Images (`registry.camunda.cloud/keycloak-ee/keycloak:bitnami-ee-*`)
Premium enterprise-grade images based on Bitnami's enterprise edition. They use the `bitnami-ee-` prefix in their tags and are available on the Camunda enterprise registry for licensed customers. For backward compatibility, these images are also available without the prefix in their own registry.

All variants include the same AWS JDBC wrapper and Camunda Identity theme functionality.

## Getting Started

- 📘 For all Keycloak-related questions, please refer to the **official Keycloak documentation** at https://www.keycloak.org/guides#getting-started.

-  🐳🚀 To **run Keycloak** in a containerized environment, follow these steps:

### Prerequisites

Make sure you have Docker installed on your machine.

### ⚙️ Starting the Container

#### Bitnami-based Images

To start the Bitnami-based image, run:

```bash
docker run --name mykeycloak -p 8443:8443 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=change_me \
        docker.io/camunda/keycloak:bitnami-26
```

#### Quay-based Images

To start the Quay-based image, run:

```bash
docker run --name mykeycloak -p 8443:8443 \
        -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
        docker.io/camunda/keycloak:quay-26 \
        start --hostname=localhost
```

Keycloak will start in production mode, using secured HTTPS communication and will be available at [https://localhost:8443](https://localhost:8443).

### 🚀 Migration Recommendation

**For production environments**, we strongly recommend using **Quay-based images** (`camunda/keycloak:quay-*`) as they:
- ✅ Receive regular security updates
- ✅ Are based on the official Red Hat Keycloak images
- ✅ Follow upstream Keycloak conventions
- ✅ Are actively maintained and supported

**Bitnami-based images** should only be used for:
- ⚠️ Temporary migration scenarios
- ⚠️ Development environments (with understanding of limited updates)
- ⚠️ Specific compatibility requirements with existing Bitnami deployments

### 🏷️ Available Tags on Docker Hub

Explore the available tags for the Camunda Keycloak Docker images on Docker Hub:

#### Quay-based Images (✅ Recommended)
- **[camunda/keycloak:quay-*](https://hub.docker.com/r/camunda/keycloak/tags)** - Based on official Keycloak from Quay.io, uses `quay-` prefix
- Base image tags at [quay.io/keycloak/keycloak](https://quay.io/repository/keycloak/keycloak?tab=tags)
#### Bitnami-based Images (⚠️ Legacy - Limited Updates)
- **[camunda/keycloak](https://hub.docker.com/r/camunda/keycloak/tags)** - Based on Bitnami Legacy Keycloak
- Base image tags at [hub.docker.com/bitnamilegacy/keycloak](https://hub.docker.com/r/bitnamilegacy/keycloak/tags)


#### Tag Conventions
For **Bitnami-based images**:
- `:<base image version>-<yyyy-mm-dd>-<iteration>`: e.g., `24-2024-03-04-004` 🏷️
- `:<base image version>`: e.g., `24.0.1-0`
- `:<major keycloak version>`: e.g., `24`

For **Quay-based images** (with `quay-` prefix):
- `:quay-<base image version>-<yyyy-mm-dd>-<iteration>`: e.g., `quay-24-2024-03-04-004` 🏷️
- `:quay-<base image version>`: e.g., `quay-24.0.1`
- `:quay-<major keycloak version>`: e.g., `quay-24`
- `:quay-optimized-<base image version>-<yyyy-mm-dd>-<iteration>`: e.g., `quay-optimized-24-2024-03-04-004` 🏷️
- `:quay-optimized-<base image version>`: e.g., `quay-optimized-24.0.1`
- `:quay-optimized-<major keycloak version>`: e.g., `quay-optimized-24`
- `:latest`: Corresponds to the latest stable build of the most recent Keycloak version from Quay (Quay is now the default latest)

## Configuration

### Bitnami-based Images
Bitnami Keycloak container image configuration is available at [hub.docker.com/bitnami/keycloak](https://hub.docker.com/r/bitnami/keycloak).

#### Environment Variable Migration (Bitnami 26.3.3+)

Starting with Keycloak 26.3.2, the following legacy environment variables have been deprecated in favor of native KC_* equivalents:

| Legacy Variable (Pre-26.3.2) | Native Variable (26.3.3+) |
|--------------------------|----------------------|
| `KEYCLOAK_ADMIN_USER` | `KC_BOOTSTRAP_ADMIN_USERNAME` |
| `KEYCLOAK_BOOTSTRAP_ADMIN_PASSWORD` | `KC_BOOTSTRAP_ADMIN_PASSWORD` |
| `KEYCLOAK_CACHE_TYPE` | `KC_CACHE` |
| `KEYCLOAK_ENABLE_STATISTICS` | `KC_METRICS_ENABLED` |
| `KEYCLOAK_ENABLE_HEALTH_ENDPOINTS` | `KC_HEALTH_ENABLED` |
| `KEYCLOAK_HOSTNAME` | `KC_HOSTNAME` |
| `KEYCLOAK_HOSTNAME_STRICT` | `KC_HOSTNAME_STRICT` |
| `KEYCLOAK_LOG_LEVEL` | `KC_LOG_LEVEL` |
| `KEYCLOAK_PROXY_HEADERS` | `KC_PROXY_HEADERS` |

You can find more information and environment variables on the [Bitnami Keycloak image](https://github.com/bitnami/containers/blob/main/bitnami/keycloak/README.md).

### Quay-based Images
Official Keycloak container configuration is documented at [keycloak.org/server/containers](https://www.keycloak.org/server/containers).

#### Image Sub-types

Quay-based images are available in two sub-types:

**Standard Images (`quay-<version>`)**
- Runtime-configurable via environment variables
- Full flexibility for all Keycloak configuration options
- Ideal for development and custom configurations

**Optimized Images (`quay-optimized-<version>`)**
- Pre-built configuration for faster startup times
- AWS JDBC wrapper and common settings baked into the image
- **Camunda-compatible path configuration** with `/auth` base path
- **AWS wrapper required**: Must use `jdbc:aws-wrapper:postgresql://...` URLs for all database connections
- Recommended for production deployments, especially with Keycloak Operator
- Reduced runtime environment variables needed

**Camunda Path Configuration (`--http-relative-path=/auth`)**

The `/auth` path is pre-configured for seamless integration with Camunda Platform 8, which expects Keycloak to be accessible at this base path. This configuration:
- ✅ Ensures compatibility with Camunda's authentication flows
- ✅ Matches the default path expected by Camunda components
- ⚠️ **Important**: All Keycloak endpoints will be prefixed with `/auth` (e.g., `/auth/realms/master`)
- ⚠️ If deploying without Camunda, consider using standard images for root path access

**XA Transactions Disabled (`--transaction-xa-enabled=false`)**

XA transactions are disabled in optimized images because:
- AWS Aurora PostgreSQL doesn't support distributed transactions
- Improves performance and reduces complexity
- Recommended configuration for cloud-native deployments

For technical details on build arguments and configuration differences, see [DEVELOPER.md](DEVELOPER.md).

## IAM Roles for Service Accounts (IRSA) Support

Since Keycloak version 21 and onwards, you can utilize the AWS Advanced JDBC Wrapper included in this image to enable IRSA (IAM Role for Service Accounts). Refer to the [Keycloak documentation](https://www.keycloak.org/server/containers) for more information.

### Kubernetes Configuration

#### Bitnami-based Images

For Kubernetes with IRSA, configure the following environment variables:

```yaml
- name: KEYCLOAK_EXTRA_ARGS
  value: "--db-driver=software.amazon.jdbc.Driver --transaction-xa-enabled=false --log-level=INFO,software.amazon.jdbc:INFO"
- name: KEYCLOAK_JDBC_PARAMS
  value: "wrapperPlugins=iam"
- name: KEYCLOAK_JDBC_DRIVER
  value: "aws-wrapper:postgresql"

- name: KEYCLOAK_DATABASE_USER
  value: db-user-name
- name: KEYCLOAK_DATABASE_NAME
  value: db-name
- name: KEYCLOAK_DATABASE_HOST
  value: db-host
- name: KEYCLOAK_DATABASE_PORT
  value: 5432

- name: KEYCLOAK_ENABLE_STATISTICS
  value: "true"
- name: KEYCLOAK_ENABLE_HEALTH_ENDPOINTS
  value: "true"
```

#### Quay-based Images

For Kubernetes with IRSA, configure the following environment variables:

**Standard Images (`quay-<version>`)**
```yaml
- name: KC_DB
  value: postgres
- name: KC_DB_DRIVER
  value: software.amazon.jdbc.Driver
- name: KC_DB_URL
  value: "jdbc:aws-wrapper:postgresql://db-host:5432/db-name?wrapperPlugins=iam"
- name: KC_DB_USERNAME
  value: db-user-name
- name: KC_TRANSACTION_XA_ENABLED
  value: "false"
- name: KC_HEALTH_ENABLED
  value: "true"
- name: KC_METRICS_ENABLED
  value: "true"
```

**Optimized Images (`quay-optimized-<version>`)**

Since the AWS JDBC wrapper driver is pre-configured in optimized images, you **must** use the `aws-wrapper` URL format even for non-IRSA deployments:

```yaml
# For IRSA (IAM authentication)
- name: KC_DB_URL
  value: "jdbc:aws-wrapper:postgresql://db-host:5432/db-name?wrapperPlugins=iam"
- name: KC_DB_USERNAME
  value: db-user-name
# No KC_DB_PASSWORD needed for IRSA

# For traditional username/password authentication
- name: KC_DB_URL
  value: "jdbc:aws-wrapper:postgresql://db-host:5432/db-name"
- name: KC_DB_USERNAME
  value: db-user-name
- name: KC_DB_PASSWORD
  value: db-password

# Note: Database driver, health/metrics, and XA settings are pre-configured
```

Don't forget to set the `serviceAccountName` of the deployment/statefulset to point to the created service account with the IRSA annotation.

#### Usage with Helm Chart

To use this image in the Helm chart [bitnami/keycloak](https://artifacthub.io/packages/helm/bitnami/keycloak), update the image used and add the necessary extra environment variables:

##### Bitnami-based Images ⚠️ **[Legacy - Consider Migration]**

> **⚠️ Migration Recommendation**: For new deployments, consider using the [Keycloak Operator](https://www.keycloak.org/operator/installation) with Quay-based images instead of Bitnami Helm charts, as they provide better long-term support and follow official Keycloak best practices.

For existing Bitnami deployments, you can use the [bitnami/keycloak](https://artifacthub.io/packages/helm/bitnami/keycloak) Helm chart:

```yaml
image: docker.io/camunda/keycloak:bitnami-26
extraEnvVars:
  - name: KEYCLOAK_EXTRA_ARGS
    value: "--db-driver=software.amazon.jdbc.Driver --transaction-xa-enabled=false --log-level=INFO,software.amazon.jdbc:INFO"
  - name: KEYCLOAK_JDBC_PARAMS
    value: "wrapperPlugins=iam"
  - name: KEYCLOAK_JDBC_DRIVER
    value: "aws-wrapper:postgresql"
externalDatabase:
  host: "aurora.rds.your.domain"
  port: 5432
  user: keycloak
  database: keycloak

global:
  security:
    # The following parameter is required due to https://github.com/bitnami/charts/issues/30850
    # It does not lower security, as it only allows forks of Bitnami images, such as this one, to be deployed by the chart.
    allowInsecureImages: true
```

#### Quay-based Images **[Recommended]**

For Quay-based images in production, we recommend using the **official Keycloak Operator** which provides better lifecycle management and follows Keycloak best practices:

**📋 Keycloak Operator Installation**: https://www.keycloak.org/operator/installation

The operator allows you to deploy Keycloak instances declaratively with proper configuration management. Here's an example Keycloak custom resource using our Camunda image:

```yaml
apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
metadata:
  name: keycloak
  namespace: keycloak
spec:
  image: docker.io/camunda/keycloak:quay-optimized-26
  instances: 3
  db:
    vendor: postgres
    host: aurora.rds.your.domain
    port: 5432
    database: keycloak
    usernameSecret:
      name: keycloak-db-secret
      key: username
    # For IRSA, omit passwordSecret to use IAM authentication
  # For IRSA support
  unsupported:
    podTemplate:
      spec:
        serviceAccountName: keycloak-service-account
        containers:
          - name: keycloak
            env:
              - name: KC_DB_URL
                value: "jdbc:aws-wrapper:postgresql://aurora.rds.your.domain:5432/keycloak?wrapperPlugins=iam"
```

Feel free to adjust the values according to your actual configuration.

## Reference

- [Keycloak Documentation](https://www.keycloak.org/documentation).
- [Keycloak Documentation: Keycloak on Amazon EKS with IRSA](https://www.keycloak.org/server/db#preparing-keycloak-for-amazon-aurora-postgresql).
- [Camunda Documentation: Keycloak on Amazon EKS with IRSA](https://docs.camunda.io/docs/self-managed/platform-deployment/helm-kubernetes/platforms/amazon-eks/irsa/).
- [Keycloak Documentation: Memory and CPU sizing](https://www.keycloak.org/high-availability/concepts-memory-and-cpu-sizing).

## Contributions

We welcome contributions and enhancements to this Docker image. Feel free to join the [GitHub Discussion](https://github.com/camunda/keycloak/issues) around enhancements of the admin bootstrapping process.

---

**Keycloak is a Cloud Native Computing Foundation incubation project.**

© Keycloak Authors 2023. © 2023 The Linux Foundation. All rights reserved. The Linux Foundation has registered trademarks and uses trademarks. For a list of trademarks of The Linux Foundation, please see our [Trademark Usage page](https://www.linuxfoundation.org/trademark-usage/).
