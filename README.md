# Camunda Keycloak Container Image

[![build-images](https://img.shields.io/badge/Camunda-FC5D0D)](https://www.camunda.com/)
[![build-images](https://github.com/camunda/keycloak/actions/workflows/build-images.yml/badge.svg?branch=main)](https://github.com/camunda/keycloak/actions/workflows/build-images.yml)
[![Docker image](https://img.shields.io/badge/docker.io%2Fcamunda%2Fkeycloak-e4f0fb?logo=docker&label=docker%20amd64,arm64)](https://hub.docker.com/r/camunda/keycloak)
[![Licence](https://img.shields.io/github/license/camunda/keycloak)](https://github.com/camunda/keycloak/blob/master/LICENSE)

This Docker image provides a generic Keycloak setup. It also includes an optional AWS wrapper, allowing for the use of AWS Identity and Access Management (IAM) Roles for Service Accounts (IRSA) for database authentication.

## Getting Started

- 📘 For all Keycloak-related questions, please refer to the **official Keycloak documentation** at https://www.keycloak.org/guides#getting-started.

-  🐳🚀 To **run Keycloak** in a containerized environment, follow these steps:

### Prerequisites

Make sure you have Docker installed on your machine.

### ⚙️ Starting the Container

To start the image, run:

```bash
docker run --name mykeycloak -p 8443:8443 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=change_me \
        docker.io/camunda/keycloak:24 \
        start --optimized
```

Keycloak will start in production mode, using secured HTTPS communication and will be available at [https://localhost:8443](https://localhost:8443).

### 🏷️ Available Tags on Docker Hub

Explore the available tags for the Camunda Keycloak Docker image on [Docker Hub](https://hub.docker.com/r/camunda/keycloak/tags):
Since we derive this image from the __base image__ of Keycloak, you can find the base image tags at [quay.io/keycloak/keycloak](https://quay.io/repository/keycloak/keycloak?tab=tags&tag=latest).

- `:<base image version>-<yyyy-mm-dd>-<iteration>`: This tag is associated with a specific date and incremental number (e.g., `24-2024-03-04-004`). It is recommended for **production use** due to its **immutable nature**. 🏷️
- `:<base image version>`: Refers to the latest build of a particular Keycloak version (e.g., `24.0.1-0`).
- `:<major keycloak version>`: Indicates the latest build of the specified major Keycloak version (e.g., `24`).
- `:latest`: Corresponds to the latest stable build of the most recent Keycloak version.

## IAM Roles for Service Accounts (IRSA) Support

Since Keycloak version 21 and onwards, you can utilize the AWS Advanced JDBC Wrapper included in this image to enable IRSA (IAM Role for Service Accounts). Refer to the [Keycloak documentation](https://www.keycloak.org/server/containers) for more information.

### Kubernetes Configuration

For Kubernetes, configure the following environment variables:

```yaml
- name: KC_DB_DRIVER
  value: software.amazon.jdbc.Driver
- name: KC_DB_URL
  value: jdbc:aws-wrapper:postgresql://[DB_HOST]:[DB_PORT]/[DB_NAME]?wrapperPlugins=iam
- name: KC_DB_USERNAME
  value: db-user-name
- name: KC_TRANSACTION_XA_ENABLED
  value: false
```

Don't forget to set the `serviceAccountName` of the deployment/statefulset to point to the created service account with the IRSA annotation.

## Reference

- [Keycloak Documentation](https://www.keycloak.org/documentation).
- [Camunda Documentation: Keycloak on Amazon EKS with IRSA](https://docs.camunda.io/docs/self-managed/platform-deployment/helm-kubernetes/platforms/amazon-eks/irsa/).
- [Keycloak Documentation: Memory and CPU sizing](https://www.keycloak.org/high-availability/concepts-memory-and-cpu-sizing).

## Contributions

We welcome contributions and enhancements to this Docker image. Feel free to join the [GitHub Discussion](https://github.com/camunda/keycloak/issues) around enhancements of the admin bootstrapping process.

---

**Keycloak is a Cloud Native Computing Foundation incubation project.**

© Keycloak Authors 2023. © 2023 The Linux Foundation. All rights reserved. The Linux Foundation has registered trademarks and uses trademarks. For a list of trademarks of The Linux Foundation, please see our [Trademark Usage page](https://www.linuxfoundation.org/trademark-usage/).
