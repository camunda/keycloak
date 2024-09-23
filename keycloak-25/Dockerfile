ARG BASE_IMAGE_NAME="docker.io/bitnami/keycloak:25.0.6-debian-12-r0"
# List of all available images with associated sha: https://hub.docker.com/r/bitnami/keycloak/tags
# Note: use the global image digest to make this image platform agnostic (see: https://github.com/camunda/zeebe/pull/14186)
ARG BASE_IMAGE_DIGEST="sha256:f9c6583ae2b5079824b35f13ecef3ad96e90af185b8df7ae0b686e83c33e257b"

# We use the identity image to copy the keycloak theme
FROM docker.io/camunda/identity:latest@sha256:74f0166a87d1630a1d98815cdfafb6aaebbcea7a296bb99f3ca00d096796200e AS identity

# Building builder image
# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST} AS builder
# use the .github/scripts/utils/get_aws_wrapper_version.sh keycloak-version script to get the value and pass it at build time
ARG AWS_JDBC_WRAPPER_VERSION

USER 0

# install maven (silence alert about version pinning of maven)
# hadolint ignore=DL3008
RUN mkdir /home/keycloak && chown keycloak /home/keycloak && \
    apt-get update && apt-get install maven -y --no-install-recommends

COPY --from=identity /app/keycloak-theme/ /opt/bitnami/keycloak/themes/identity
RUN chown 1001:1000 -R /opt/bitnami/keycloak/themes

USER 1001

WORKDIR /home/keycloak

# Install the custom providers
# download the wrapper from github, then fetch the dependencies from maven
RUN curl -fL "https://repo1.maven.org/maven2/software/amazon/jdbc/aws-advanced-jdbc-wrapper/${AWS_JDBC_WRAPPER_VERSION}/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.pom" \
    -o /home/keycloak/pom.xml \
    && chown 1001:1000 /home/keycloak/pom.xml \
    && chmod 0644 /home/keycloak/pom.xml && \

    cat /home/keycloak/pom.xml && mvn install && \
    cp /home/keycloak/.m2/repository/software/amazon/*/*/*/*.jar /opt/bitnami/keycloak/providers/ && \

    curl -fL "https://github.com/aws/aws-advanced-jdbc-wrapper/releases/download/${AWS_JDBC_WRAPPER_VERSION}/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar" \
    -o /opt/bitnami/keycloak/providers/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar \
    && chown 1001:1000 /opt/bitnami/keycloak/providers/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar \
    && chmod 0644 /opt/bitnami/keycloak/providers/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar && \

    ls -alh /opt/bitnami/keycloak/providers/


RUN /opt/bitnami/keycloak/bin/kc.sh build

##### FINAL Keycloak IMAGE # ####

# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST}
# leave the values below unset to use the default value at the top of the file
ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_DIGEST

# use the .github/scripts/utils/get_aws_wrapper_version.sh keycloak-version script to get the value and pass it at build time
ARG AWS_JDBC_WRAPPER_VERSION

# Copy the previously built aws jdbc drivers
COPY --chown=1001:1000 --from=builder /opt/bitnami/keycloak/ /opt/bitnami/keycloak/

COPY --chown=1001:1000 --from=builder /opt/bitnami/keycloak/themes/identity /opt/bitnami/keycloak/themes/identity


# common, k8s, openshift and OCI labels:
# OCI: https://github.com/opencontainers/image-spec/blob/main/annotations.md
# OCP: https://docs.openshift.com/container-platform/4.10/openshift_images/create-images.html#defining-image-metadata
LABEL maintainer="Camunda" \
      name="camunda/keycloak" \
      summary="Keycloak bitnami with AWS wrapper" \
      io.k8s.description="Keycloak bitnami with AWS wrapper." \
      io.k8s.display-name="keycloak" \
      description="Keycloak bitnami with AWS JDBC wrapper." \
      jdbc.aws-jdbc-wrapper.version="${AWS_JDBC_WRAPPER_VERSION}" \
      org.opencontainers.image.authors="Camunda" \
      org.opencontainers.image.vendor="Camunda" \
      org.opencontainers.image.documentation="https://hub.docker.com/camunda/keycloak/" \
      org.opencontainers.image.licenses="Apache License 2.0" \
      org.opencontainers.image.base.name="docker.io/library/${BASE_IMAGE_NAME}" \
      org.opencontainers.image.base.digest="${BASE_IMAGE_DIGEST}" \
      io.openshift.tags="bpmn,identity,keycloak,camunda,bitnami" \
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
