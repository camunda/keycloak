FROM docker.io/gradle:jdk17-focal as lib

WORKDIR /home/gradle

COPY build.gradle /home/gradle

RUN gradle copyDependencies

# quay.io is the new repository of keycloak (https://lists.jboss.org/archives/list/keycloak-user@lists.jboss.org/message/7CRWKAAYI5WJTUXUZR6K73XV7P4TLZZ2/)
FROM quay.io/keycloak/keycloak:22 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=lib /home/gradle/lib /opt/keycloak/providers

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

# final keycloak image

FROM quay.io/keycloak/keycloak:22

# OCI annotations to image
LABEL maintainer="Camunda" \
      name="camunda/keycloak" \
      summary="Keycloak with AWS wrapper" \
      io.k8s.description="Keycloak with AWS wrapper." \
      io.k8s.display-name="keycloak" \
      description="Keycloak with AWS wrapper." \
      org.opencontainers.image.authors="Camunda" \
      org.opencontainers.image.vendor="Camunda" \
      org.opencontainers.image.documentation="https://hub.docker.com/camunda/keycloak/" \
      org.opencontainers.image.licenses="Apache License 2.0"
      # the following labels are generated at buildtime - see https://github.com/docker/metadata-action
      # org.opencontainers.image.title
      # org.opencontainers.image.description
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
