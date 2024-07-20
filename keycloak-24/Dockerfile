ARG BASE_IMAGE_NAME="docker.io/bitnami/keycloak:24.0.5-debian-12-r5"
# List of all available images with associated sha: https://hub.docker.com/r/bitnami/keycloak/tags
# Note: use the global image digest to make this image platform agnostic (see: https://github.com/camunda/zeebe/pull/14186)
ARG BASE_IMAGE_DIGEST="sha256:c383addc996e7243ca0d5738f2cec375ee914ca29be4bba0bce3118fa82dc7bc"

# Building builder image
# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST} as builder
# use the .github/scripts/utils/get_aws_wrapper_version.sh keycloak-version script to get the value and pass it at build time
ARG AWS_JDBC_WRAPPER_VERSION

USER 0

# install maven (silence alert about version pinning of maven)
# hadolint ignore=DL3008
RUN mkdir /home/keycloak && chown keycloak /home/keycloak && \
    apt-get update && apt-get install maven -y --no-install-recommends

USER 1001

WORKDIR /home/keycloak

# download the wrapper from github, then fetch the dependencies from maven
ADD --chown=1001 "https://github.com/awslabs/aws-advanced-jdbc-wrapper/releases/download/${AWS_JDBC_WRAPPER_VERSION}/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar" "/opt/bitnami/keycloak/providers/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar"
ADD --chown=1001 "https://repo1.maven.org/maven2/software/amazon/jdbc/aws-advanced-jdbc-wrapper/${AWS_JDBC_WRAPPER_VERSION}/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.pom" /home/keycloak/pom.xml

RUN cat /home/keycloak/pom.xml && mvn install && \
    cp /home/keycloak/.m2/repository/software/amazon/awssdk/*/*/*.jar /opt/bitnami/keycloak/providers/

RUN /opt/bitnami/keycloak/bin/kc.sh build

##### FINAL Keycloak IMAGE #####

# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST}
# leave the values below unset to use the default value at the top of the file
ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_DIGEST

# use the .github/scripts/utils/get_aws_wrapper_version.sh keycloak-version script to get the value and pass it at build time
ARG AWS_JDBC_WRAPPER_VERSION

# Copy the previously built aws jdbc drivers
COPY --from=builder /opt/bitnami/keycloak/ /opt/bitnami/keycloak/

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
