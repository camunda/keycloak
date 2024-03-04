# Camunda Keycloak Container Image

[Camunda](https://www.camunda.com/)

This Docker image provides a generic Keycloak setup. It also includes an optional AWS wrapper, allowing for the use of AWS Identity and Access Management (IAM) Roles for Service Accounts (IRSA) for database authentication.

## Getting Started

To run Keycloak in a containerized environment, follow these steps:

### Prerequisites

Make sure you have Docker installed on your machine.

### Starting the Container

To start the image, run:

```bash
docker run --name mykeycloak -p 8443:8443 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=change_me \
        docker.io/camunda/keycloak:keycloak-23 \
        start --optimized
```

Keycloak will start in production mode, using secured HTTPS communication and will be available at [https://localhost:8443](https://localhost:8443).

### Exposing the Container to a Different Port

If you want to expose the container using a different port, use the following command:

```bash
docker run --name mykeycloak -p 3000:8443 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=change_me \
        docker.io/camunda/keycloak:keycloak-23 \
        start --optimized --hostname-port=3000
```

Now you can access the server at [https://localhost:3000](https://localhost:3000).

### Trying Keycloak in Development Mode

For development or testing purposes, use the development mode:

```bash
docker run --name mykeycloak -p 8080:8080 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=change_me \
        docker.io/camunda/keycloak:keycloak-23 \
        start-dev
```

Avoid using this mode in production environments due to insecure defaults.

### Importing A Realm On Startup

If you have a realm to import, use the following command:

```bash
docker run --name keycloak_unoptimized -p 8080:8080 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=change_me \
        -v /path/to/realm/data:/opt/keycloak/data/import \
        docker.io/camunda/keycloak:keycloak-23 \
        start-dev --import-realm
```

### Specifying Different Memory Settings

To specify different memory settings, use the following command:

```bash
docker run --name mykeycloak -p 8080:8080 \
        -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=change_me \
        -e JAVA_OPTS_KC_HEAP="-XX:MaxHeapFreeRatio=30 -XX:MaxRAMPercentage=65" \
        docker.io/camunda/keycloak:keycloak-23 \
        start-dev
```

## IAM Roles for Service Accounts (IRSA) Support

For Keycloak versions 21+, you can use the AWS Advanced JDBC Wrapper to support IRSA. Check the [Keycloak documentation](https://www.keycloak.org/server/containers) for details.

## Kubernetes Configuration

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

Don't forget to set the `serviceAccountName` of the deployment/statefulset to the created service account with the IRSA annotation.

### Building the Image

Navigate to the `keycloak-23` directory and execute the following command:

```bash
docker build . -t docker.io/camunda/keycloak:keycloak-23
```

This Dockerfile includes the necessary dependencies and configurations for AWS Advanced JDBC Wrapper.

Feel free to explore the [Camunda Documentation](https://docs.camunda.io/docs/self-managed/platform-deployment/helm-kubernetes/platforms/amazon-eks/irsa/) for additional details.

## Contributions

We welcome contributions and enhancements to this Docker image. Feel free to join the [GitHub Discussion](https://github.com/camunda/keycloak/issues) around enhancements of the admin bootstrapping process.

---

**Keycloak is a Cloud Native Computing Foundation incubation project.**

© Keycloak Authors 2023. © 2023 The Linux Foundation. All rights reserved. The Linux Foundation has registered trademarks and uses trademarks. For a list of trademarks of The Linux Foundation, please see our [Trademark Usage page](https://www.linuxfoundation.org/trademark-usage/).
