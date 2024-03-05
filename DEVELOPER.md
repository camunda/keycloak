# Developer's Guide

Welcome to the development reference for Keycloak by Camunda! This document provides guidance on setting up a basic testing environment, running unit tests, and testing changes locally.

## Setting up a New Version of Keycloak

When adding a new version of Keycloak, follow these steps:

1. **Create a Directory:**
   - Create a directory for the new version at the root of this repository.
   - Name the directory using the pattern: `keycloak-<major_version>`, where `<major_version>` represents the major release version.

2. **Major Version Considerations:**
   - Note that Keycloak supports only one version of postgres per major release.
   - Find the version in the `pom.xml` file of the project. You can locate it [here](https://github.com/keycloak/keycloak/blob/release/24.0/pom.xml).
   - The pipeline of tests will automatically fetch this file and use the referenced version. For example: `<postgresql.version>15</postgresql.version>` indicates the target test version.
   - Locally, you can use this version for testing.

3. **Update to the Latest Keycloak Version:**
   - Always ensure that you are using the latest version of Keycloak for development and testing.
   - Create a symbolic link named `keycloak-latest` that points to the directory of the most recent Keycloak version. Use the following command as an example:
     ```bash
     ln -s keycloak-<latest_version> keycloak-latest
     ```
   Replace `<latest_version>` with the actual version number. This symbolic link will simplify referencing the latest version during development.

Following these steps ensures a smooth integration of new Keycloak versions, consistent testing across the development environment, and easy access to the latest version. Happy coding!
