FROM docker.io/gradle:jdk17-focal as lib

WORKDIR /home/gradle

COPY build.gradle /home/gradle

RUN gradle copyDependencies

# quay.io is the new repository of keycloak (https://lists.jboss.org/archives/list/keycloak-user@lists.jboss.org/message/7CRWKAAYI5WJTUXUZR6K73XV7P4TLZZ2/)
FROM quay.io/keycloak/keycloak:22.0 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=lib /home/gradle/lib /opt/keycloak/providers

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

# final keycloak image

FROM quay.io/keycloak/keycloak:22.0

# OCI annotations to image
LABEL org.opencontainers.image.authors="Camunda" \
      org.opencontainers.image.title="Camunda keycloak" \
      org.opencontainers.image.description="Camunda keycloak image" \
      org.opencontainers.image.documentation="https://hub.docker.com/camunda/keycloak/" \
      org.opencontainers.image.vendor="Camunda" \
      org.opencontainers.image.url="https://github.com/camunda/container-keycloak" \
      org.opencontainers.image.licenses="TODO: TBD"

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_DB=postgres

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
