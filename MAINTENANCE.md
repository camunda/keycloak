# MAINTENANCE.md

_This file serves as a reference for the lifecycle of this project._
_Note: Ensure to keep this document updated with any changes in maintenance procedures, dependencies, actions, or restrictions._

## Maintenance Procedures

### Before New Releases

- Update documentation related to new features or changes.
    - `README.md`
    - DockerHub [Camunda Keycloak Docker Hub](https://hub.docker.com/repository/docker/camunda/keycloak/general)
    - Official Camunda documentation:
        - [Amazon EKS IRSA](https://github.com/camunda/camunda-docs/blob/main/docs/self-managed/setup/deploy/amazon/amazon-eks/irsa.md)

- Make internal announcements on slack regarding upcoming releases.
    - `#infex-internal`
    - `#engineering` if relevant

- Refer to `DEVELOPER.md` to see the release process.

### After New Releases

_Nothing referenced yet._

## Dependencies

### Upstream Dependencies: dependencies of this project

- **bitnami/containers**: This project uses the Keycloak image from [Bitnami Containers Repository](https://github.com/bitnami/containers).

### Downstream Dependencies: things that depend on this project

- **Distribution Team**: Utilizes this project in various aspects, including the [Camunda Platform Helm Chart](https://github.com/camunda/camunda-platform-helm/blob/main/charts/camunda-platform/values-latest.yaml).

## Actions

- Notify the **Distribution Team** of any new releases, especially if there are breaking changes or critical updates.

## Restrictions

- Versions of Keycloak maintained should align with those supported by the Camunda platform. Refer to the [supported environments documentation](https://docs.camunda.io/docs/reference/supported-environments/#component-requirements) for the latest information (make sure to browse other supported Camunda versions of the documentation to have a complete list of the versions).
- Never remove images from the registry, even if the sources are deprecated or removed.
