# Consume it from the bases.yml
# docker build \
#  --build-arg BASE_IMAGE_NAME="$(yq e '.sources.hub.name' bases.yml | cut -d@ -f1)" \
#  --build-arg BASE_IMAGE_DIGEST="$(yq e '.sources.hub.name' bases.yml | cut -d@ -f2)" \
#  -t your-image-name .
ARG BASE_IMAGE_NAME=""
ARG BASE_IMAGE_DIGEST=""

# We use the identity image to copy the keycloak theme
FROM docker.io/camunda/identity:latest@sha256:f8fe4e00c1a67992f76f2bcc35297e4e837da53c4ab118607ee306ad8412a062 AS identity

# Building builder image
# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST} AS builder

# renovate: datasource=github-tags depName=aws/aws-advanced-jdbc-wrapper
ARG AWS_JDBC_WRAPPER_VERSION=2.3.9

USER 0

# install maven (silence alert about version pinning of maven)
# hadolint ignore=DL3008
RUN mkdir /home/keycloak && chown keycloak /home/keycloak && \
    apt-get update && apt-get install maven -y --no-install-recommends

COPY --from=identity /app/keycloak-theme/ /opt/bitnami/keycloak/themes/identity
RUN chown 1001:1000 -R /opt/bitnami/keycloak/themes

USER 1001

WORKDIR /home/keycloak

# download the wrapper from github, then fetch the dependencies from maven
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

##### FINAL Keycloak IMAGE #####

# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST}
# leave the values below unset to use the default value at the top of the file
ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_DIGEST

# renovate: datasource=github-tags depName=aws/aws-advanced-jdbc-wrapper
ARG AWS_JDBC_WRAPPER_VERSION=2.3.9

# Copy the previously built aws jdbc drivers
COPY --from=builder /opt/bitnami/keycloak/ /opt/bitnami/keycloak/

COPY --from=builder /opt/bitnami/keycloak/themes/identity /opt/bitnami/keycloak/themes/identity

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
