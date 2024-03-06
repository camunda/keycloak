# Developer's Guide

Welcome to the development reference for Keycloak by Camunda! This document provides guidance on setting up a basic testing environment, running unit tests, and testing changes locally.

## Setting up a New Version of Keycloak

When adding a new version of Keycloak, follow these steps:

1. **Create a Directory:**
   - Create a directory for the new version at the root of this repository.
   - Name the directory using the pattern: `keycloak-<major_version>`, where `<major_version>` represents the major release version.

2. **Major Version Considerations:**
   - Note that Keycloak supports only one version of Postgres per major release.
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

4. **Release Tagging and Versioning:**
   - When creating a new release, the version is tagged with a suffix consisting of the date and an incremental number, e.g., `2024-03-06-001`.
   - All images are rebuilt and republished with the final image tag being `keycloak-<major_version>-<release_date>-<incremental_number>`. This process occurs even if there are no changes.
   - The rationale for rebuilding images is to account for regular system patches in the base container (UBI). This ensures a consistent and up-to-date foundation, especially considering the frequent release cycles of Keycloak (every 3 months) and the unpredictable nature of CVE patches.

5. **Versioning Strategy:**
   - Currently, versioning is based only on the major release. Minor releases are bumped without prior notification.
   - It is recommended to use the complete tagged version for production. For development purposes, the tags `keycloak-<major_version>-latest` and `latest` are available.

Following these steps ensures a smooth integration of new Keycloak versions, consistent testing across the development environment, and easy access to the latest version. Happy coding!
