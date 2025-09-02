# Camunda Keycloak Container Image

[![build-images](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![build-images](https://github.com/camunda/keycloak/actions/workflows/build-images.yml/badge.svg?branch=main)](https://github.com/camunda/keycloak/actions/workflows/build-images.yml)
[![Docker image](https://img.shields.io/badge/docker.io%2Fcamunda%2Fkeycloak-e4f0fb?logo=docker&label=docker%20amd64,arm64)](https://hub.docker.com/r/camunda/keycloak/tags)
[![Docker image Quay](https://img.shields.io/badge/docker.io%2Fcamunda%2Fkeycloak--quay-e4f0fb?logo=docker&label=docker%20amd64,arm64)](https://hub.docker.com/r/camunda/keycloak-quay/tags)
[![Licence](https://img.shields.io/github/license/camunda/keycloak)](https://github.com/camunda/keycloak/blob/main/LICENSE)

This Docker image provides a generic Keycloak setup based on [bitnami/keycloak](https://hub.docker.com/r/bitnami/keycloak) or the [official Keycloak image from Quay.io](https://quay.io/repository/keycloak/keycloak). It also includes:
* an optional AWS wrapper, allowing for the use of AWS Identity and Access Management (IAM) Roles for Service Accounts (IRSA) for database authentication.
* an optional [Camunda Identity](https://docs.camunda.io/docs/self-managed/identity/what-is-identity/) login theme

## Image Variants

This repository provides two main image variants:

### 🐳 Bitnami-based Images (`camunda/keycloak`)
Based on the [Bitnami Keycloak image](https://hub.docker.com/r/bitnami/keycloak), these images use Bitnami's environment variable conventions and are well-suited for users already familiar with Bitnami's ecosystem.

### 🦆 Quay-based Images (`camunda/keycloak-quay`)
Based on the [official Keycloak image from Quay.io](https://quay.io/repository/keycloak/keycloak), these images follow the official Keycloak configuration patterns and are ideal for users who prefer the upstream container conventions.

Both variants include the same AWS JDBC wrapper and Camunda Identity theme functionality.

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
        docker.io/camunda/keycloak:26
```

#### Quay-based Images

To start the Quay-based image, run:

```bash
docker run --name mykeycloak -p 8443:8443 \
        -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me \
        docker.io/camunda/keycloak-quay:26 \
        start --optimized --hostname=localhost
```

Keycloak will start in production mode, using secured HTTPS communication and will be available at [https://localhost:8443](https://localhost:8443).

### 🏷️ Available Tags on Docker Hub

Explore the available tags for the Camunda Keycloak Docker images on Docker Hub:

#### Bitnami-based Images
- **[camunda/keycloak](https://hub.docker.com/r/camunda/keycloak/tags)** - Based on Bitnami Keycloak
- Base image tags at [hub.docker.com/bitnami/keycloak](https://hub.docker.com/r/bitnami/keycloak/tags)

#### Quay-based Images
- **[camunda/keycloak-quay](https://hub.docker.com/r/camunda/keycloak-quay/tags)** - Based on official Keycloak from Quay.io
- Base image tags at [quay.io/keycloak/keycloak](https://quay.io/repository/keycloak/keycloak?tab=tags)

#### Tag Conventions (for both variants)
- `:<base image version>-<yyyy-mm-dd>-<iteration>`: This tag is associated with a specific date and incremental number (e.g., `24-2024-03-04-004`). It is recommended for **production use** due to its **immutable nature**. 🏷️
- `:<base image version>`: Refers to the latest build of a particular Keycloak version (e.g., `24.0.1-0`).
- `:<major keycloak version>`: Indicates the latest build of the specified major Keycloak version (e.g., `24`).
- `:latest`: Corresponds to the latest stable build of the most recent Keycloak version (only available for Bitnami-based images).

## Configuration

### Bitnami-based Images
Bitnami Keycloak container image configuration is available at [hub.docker.com/bitnami/keycloak](https://hub.docker.com/r/bitnami/keycloak).

### Quay-based Images
Official Keycloak container configuration is documented at [keycloak.org/server/containers](https://www.keycloak.org/server/containers).

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

```yaml
- name: KC_DB
  value: postgres
- name: KC_DB_URL
  value: "jdbc:aws-wrapper:postgresql://db-host:5432/db-name?wrapperPlugins=iam"
- name: KC_DB_USERNAME
  value: db-user-name
- name: KC_DB_DRIVER
  value: "software.amazon.jdbc.Driver"

- name: KC_HEALTH_ENABLED
  value: "true"
- name: KC_METRICS_ENABLED
  value: "true"
```

Don't forget to set the `serviceAccountName` of the deployment/statefulset to point to the created service account with the IRSA annotation.

#### Usage with Helm Chart

To use this image in the Helm chart [bitnami/keycloak](https://artifacthub.io/packages/helm/bitnami/keycloak), update the image used and add the necessary extra environment variables:

##### Bitnami-based Images

```yaml
image: docker.io/camunda/keycloak:26
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

##### Quay-based Images

For official Keycloak images, you would typically use a different Helm chart like [codecentric/keycloak](https://artifacthub.io/packages/helm/codecentric/keycloak):

```yaml
image:
  repository: docker.io/camunda/keycloak-quay
  tag: "26"
extraEnv: |
  - name: KC_DB
    value: postgres
  - name: KC_DB_URL
    value: "jdbc:aws-wrapper:postgresql://aurora.rds.your.domain:5432/keycloak?wrapperPlugins=iam"
  - name: KC_DB_USERNAME
    value: keycloak
  - name: KC_DB_DRIVER
    value: "software.amazon.jdbc.Driver"
  - name: KC_HEALTH_ENABLED
    value: "true"
  - name: KC_METRICS_ENABLED
    value: "true"
command:
  - "/opt/keycloak/bin/kc.sh"
args:
  - "start"
  - "--optimized"
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
