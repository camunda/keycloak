# quay.io is the new repository of keycloak (https://lists.jboss.org/archives/list/keycloak-user@lists.jboss.org/message/7CRWKAAYI5WJTUXUZR6K73XV7P4TLZZ2/)
ARG BASE_IMAGE_NAME="quay.io/keycloak/keycloak:24.0"
ARG BASE_IMAGE_SHA_AMD64="sha256:050b5430f5a2f417ef41dd5ccdda70f900761bb757d08a17dd6957796e61acc9"
ARG BASE_IMAGE_SHA_ARM64="sha256:be4ff90d66bd1cdfe79610a90eae2b187dff9926e5c1a99200eaf62b41433600"


FROM docker.io/gradle:jdk17-focal as lib

WORKDIR /home/gradle

COPY build.gradle /home/gradle

RUN gradle copyDependencies

# Building prod image amd64
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_SHA_AMD64} as prod-amd64

# leave unset to use the default value at the top of the file
ARG BASE_IMAGE_SHA_AMD64
ARG BASE_SHA="${BASE_IMAGE_SHA_AMD64}"

# Building prod image arm64
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_SHA_ARM64} as prod-arm64

# leave unset to use the default value at the top of the file
ARG BASE_IMAGE_SHA_ARM64
ARG BASE_SHA="${BASE_IMAGE_SHA_ARM64}"

# Building builder image
# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME} as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=lib /home/gradle/lib /opt/keycloak/providers

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

##### FINAL Keycloak IMAGE #####
# The value of TARGETARCH is provided by the build command from docker and based on that value, prod-amd64 or
# prod-arm64 will be built as defined above
# hadolint ignore=DL3006
FROM prod-${TARGETARCH}

# leave the values below unset to use the default value at the top of the file
ARG BASE_IMAGE_NAME
ARG BASE_SHA

# common, k8s, openshift and OCI labels:
# OCI: https://github.com/opencontainers/image-spec/blob/main/annotations.md
# OCP: https://docs.openshift.com/container-platform/4.10/openshift_images/create-images.html#defining-image-metadata
LABEL maintainer="Camunda" \
      name="camunda/keycloak" \
      summary="Keycloak with AWS wrapper" \
      io.k8s.description="Keycloak with AWS wrapper." \
      io.k8s.display-name="keycloak" \
      description="Keycloak with AWS wrapper." \
      org.opencontainers.image.authors="Camunda" \
      org.opencontainers.image.vendor="Camunda" \
      org.opencontainers.image.documentation="https://hub.docker.com/camunda/keycloak/" \
      org.opencontainers.image.licenses="Apache License 2.0" \
      org.opencontainers.image.base.name="docker.io/library/${BASE_IMAGE_NAME}" \
      org.opencontainers.image.base.digest="${BASE_SHA}" \
      io.openshift.tags="bpmn,identity,keycloak,camunda" \
      io.openshift.min-memory="1Gi" \
      io.openshift.min-cpu="1"

      # the following labels are generated at buildtime - see https://github.com/docker/metadata-action
      # org.opencontainers.image.title
      # org.opencontainers.image.description
      # org.opencontainers.image.url
      # org.opencontainers.image.created
      # org.opencontainers.image.revision
      # org.opencontainers.image.source
      # org.opencontainers.image.version

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_DB=postgres

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
