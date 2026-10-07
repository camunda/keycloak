# MAINTENANCE.md

_This file serves as a reference for the lifecycle of this project._
_Note: Ensure to keep this document updated with any changes in maintenance procedures, dependencies, actions, or restrictions._

## Maintenance Procedures

### Before New Releases

- Update documentation related to new features or changes.
    - `README.md`
    - DockerHub [Camunda Keycloak Docker Hub](https://hub.docker.com/repository/docker/camunda/keycloak)
    - Official Camunda documentation:
        - [Amazon EKS IRSA](https://github.com/camunda/camunda-docs/blob/main/docs/self-managed/deployment/helm/cloud-providers/amazon/amazon-eks/irsa.md)

- Make internal announcements on slack regarding upcoming releases.
    - `#infex-internal`
    - `#engineering` if relevant

- Refer to `DEVELOPER.md` to see the release process.

### After New Releases

_Nothing referenced yet._

### On-demand build of a specific version

Renovate only tracks the newest base image of each source. To build and publish an older patch line, run the `build-images` workflow manually with a replacement for `keycloak-<major>/bases.yml`:

```bash
gh workflow run build-images.yml \
  -f keycloak_major=26 \
  -f publish=true \
  -f bases_override='{sources: {prem: {image: {repository: registry.camunda.cloud/vendor-ee/keycloak, tag: <tag>@sha256:<digest>}}}}'
```

- Only the sources listed in `bases_override` are built, tested and published.
- Each tag must be pinned with its index digest (see the `skopeo` commands in `bases.yml`).
- Only the exact version tags are published (for example `bitnami-ee-<tag>` and `bitnami-ee-<semver>`). The `<major>` and `latest` tags are not changed.
- Leave `publish` unchecked to run only the build and the tests.

## Dependencies

### Upstream Dependencies: dependencies of this project

- **bitnami/containers**: This project uses the Keycloak image from [Bitnami Containers Repository](https://github.com/bitnami/containers).

### Downstream Dependencies: things that depend on this project

- **Distribution Team**: Utilizes this project in various aspects, including the [Camunda Platform Helm Chart](https://github.com/camunda/camunda-platform-helm/blob/main/charts/camunda-platform-8.6/values-latest.yaml).

## Actions

- Notify the **Distribution Team** of any new releases, especially if there are breaking changes or critical updates.

## Restrictions

- Versions of Keycloak maintained should align with those supported by the Camunda platform. Refer to the [supported environments documentation](https://docs.camunda.io/docs/reference/supported-environments/#component-requirements) for the latest information (make sure to browse other supported Camunda versions of the documentation to have a complete list of the versions).
- Never remove images from the registry, even if the sources are deprecated or removed.
