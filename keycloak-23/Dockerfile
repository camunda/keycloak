ARG BASE_IMAGE_NAME="docker.io/bitnami/keycloak:23.0.7-debian-12-r3"
# List of all available images with associated sha: https://hub.docker.com/r/bitnami/keycloak/tags
# Note: use the global image digest to make this image platform agnostic (see: https://github.com/camunda/zeebe/pull/14186)
ARG BASE_IMAGE_DIGEST="sha256:eabfbdd679042f40612388aed560e3e7f809c3d4a04e5755a7cac22c9270e5a5"

##### FINAL Keycloak IMAGE #####

# hadolint ignore=DL3006
FROM ${BASE_IMAGE_NAME}@${BASE_IMAGE_DIGEST}
# leave the values below unset to use the default value at the top of the file
ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_DIGEST

# use the .github/scripts/utils/get_aws_wrapper_version.sh keycloak-version script to get the value and pass it at build time
ARG AWS_JDBC_WRAPPER_VERSION
# use the .github/scripts/utils/get_awssdk_jar_version.sh
ARG AWS_SDK_VERSION

# switch back to root to modify scripts
USER 0

# download aws-jdbc-wrapper from the official keycloak release
RUN curl -L "https://github.com/awslabs/aws-advanced-jdbc-wrapper/releases/download/${AWS_JDBC_WRAPPER_VERSION}/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar" -o "/opt/bitnami/keycloak/providers/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar" && \
    curl -L "https://repo1.maven.org/maven2/software/amazon/awssdk/rds/${AWS_SDK_VERSION}/rds-${AWS_SDK_VERSION}.jar" -o "/opt/bitnami/keycloak/providers/rds-${AWS_SDK_VERSION}.jar" && \
    chown keycloak "/opt/bitnami/keycloak/providers/rds-${AWS_SDK_VERSION}.jar" "/opt/bitnami/keycloak/providers/aws-advanced-jdbc-wrapper-${AWS_JDBC_WRAPPER_VERSION}.jar"


# Patch the image scripts to support custom JDBC driver until https://github.com/bitnami/charts/issues/18808#issuecomment-1866638783 is resolved
# hadolint ignore=SC2016
RUN sed -i '/KEYCLOAK_JDBC_PARAMS$/a\    KEYCLOAK_JDBC_DRIVER' /opt/bitnami/scripts/keycloak-env.sh && \
    sed -i '/^export KEYCLOAK_JDBC_PARAMS="${KEYCLOAK_JDBC_PARAMS:-}"/a \
KEYCLOAK_JDBC_DRIVER="${KEYCLOAK_JDBC_DRIVER:-postgresql}"\nexport KEYCLOAK_JDBC_DRIVER="${KEYCLOAK_JDBC_DRIVER:-}"' /opt/bitnami/scripts/keycloak-env.sh && \
    sed -i 's/"jdbc:postgresql:/\"jdbc:${KEYCLOAK_JDBC_DRIVER}:/g' /opt/bitnami/scripts/libkeycloak.sh


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
      aws.sdk.version="${AWS_SDK_VERSION}" \
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

# Switch back to unprivileged user
USER 1001

# Rebuild as we added a provided
RUN /opt/bitnami/keycloak/bin/kc.sh build
