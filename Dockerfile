FROM gradle:jdk17-focal as lib

WORKDIR /home/gradle

COPY build.gradle /home/gradle

RUN gradle copyDependencies

FROM keycloak/keycloak:22.0 as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=lib /home/gradle/lib /opt/keycloak/providers

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

FROM keycloak/keycloak:22.0

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_DB=postgres

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
