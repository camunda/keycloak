# quay.io is the new repository of keycloak (https://lists.jboss.org/archives/list/keycloak-user@lists.jboss.org/message/7CRWKAAYI5WJTUXUZR6K73XV7P4TLZZ2/)
ARG BASE_IMAGE_NAME="quay.io/keycloak/keycloak:24.0.1-0"
# List of all available images with associated sha: https://quay.io/repository/keycloak/keycloak?tab=tags
# Note: use the global image digest to make this image platform agnostic (see: https://github.com/camunda/zeebe/pull/14186)
ARG BASE_IMAGE_DIGEST="sha256:8e38bc8a4e0606e38a37401422dfbf414e2b73797952dfe94c9b56e2f9207897"

FROM docker.io/gradle:jdk17-focal@sha256:17e0c6bec6cb2c7f4240315d7a957c6b9058a5c137c2f8b37760ac327111ce87 as lib

WORKDIR /home/gradle

COPY build.gradle /home/gradle

RUN gradle copyDependencies

# Building builder image
# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST} as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=lib /home/gradle/lib /opt/keycloak/providers

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

##### FINAL Keycloak IMAGE #####
# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST}

# leave the values below unset to use the default value at the top of the file
ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_DIGEST

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
      org.opencontainers.image.base.digest="${BASE_IMAGE_DIGEST}" \
      io.openshift.tags="bpmn,identity,keycloak,camunda" \
      io.openshift.min-memory="1Gi" \
      io.openshift.min-cpu="1"

      # cpu and ram allocation reference: https://www.keycloak.org/high-availability/concepts-memory-and-cpu-sizing

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
