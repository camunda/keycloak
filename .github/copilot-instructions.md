# Camunda Keycloak Container Images - Repository Context

## Repository Purpose
This repository builds and maintains containerized Keycloak images for Camunda with three main variants:
- **Quay-based images** (`quay-*` tags): Official Keycloak from Quay.io with AWS JDBC wrapper and runtime configuration
- **Bitnami-based images** (`bitnami-*` tags): Based on Bitnami Legacy Keycloak
- **Enterprise images** (`bitnami-ee-*` tags): Premium enterprise-grade images

## Key Technical Architecture

### AWS Integration Features
- **IRSA Support**: Enables passwordless database authentication using AWS IAM roles
- **AWS JDBC Wrapper**: Provides connection failover, monitoring, and IAM authentication
- **Connection Types**:
  - Local PostgreSQL: `jdbc:postgresql://postgres:5432/db`
  - AWS Aurora with IRSA: `jdbc:aws-wrapper:postgresql://aurora.domain:5432/db?wrapperPlugins=iam`

### Build System
- **Multi-stage Dockerfiles**: Separate build for dependencies (AWS wrapper, Identity theme)
- **Version Matrix**: Supports Keycloak versions 23, 24, 25, 26
- **CI/CD Pipeline**: Automated builds, tests (local + Aurora), and publishing to Docker Hub/Camunda registry

## Important Configuration Patterns

### Docker Compose Files
- `docker-compose.bitnami.yml`: For Bitnami-based images version 26+ using native KC_* environment variables
- `docker-compose.bitnamiold.yml`: For Bitnami-based images before version 26 using legacy KEYCLOAK_* environment variables
- `docker-compose.quay.yml`: For Quay-based images with runtime AWS wrapper configuration

### Environment Variables (Bitnami images 26+)
```yaml
KC_BOOTSTRAP_ADMIN_USERNAME: admin
KC_BOOTSTRAP_ADMIN_PASSWORD: admin
KC_HTTP_RELATIVE_PATH: /
KC_CACHE: ispn
KC_PROXY_HEADERS: xforwarded
KC_HEALTH_ENABLED: true
KC_METRICS_ENABLED: true
KC_HOSTNAME: localhost
KC_HOSTNAME_STRICT: false
KC_HTTP_ENABLED: true
KC_LOG_LEVEL: INFO
```

### Environment Variables (Bitnami images <26 - Legacy)
```yaml
KEYCLOAK_ADMIN_USER: admin
KEYCLOAK_BOOTSTRAP_ADMIN_PASSWORD: admin
KEYCLOAK_CACHE_TYPE: ispn
KEYCLOAK_PROXY_HEADERS: xforwarded
KEYCLOAK_ENABLE_STATISTICS: true
KEYCLOAK_ENABLE_HEALTH_ENDPOINTS: true
KEYCLOAK_HOSTNAME: localhost
KEYCLOAK_HOSTNAME_STRICT: false
KEYCLOAK_HTTP_ENABLED: true
KEYCLOAK_LOG_LEVEL: INFO
```

### Environment Variables (Quay images)
```yaml
KC_DB: postgres
KC_DB_DRIVER: software.amazon.jdbc.Driver
KC_DB_URL: jdbc:aws-wrapper:postgresql://host:port/db?params
KC_DB_USERNAME: username
KC_DB_PASSWORD: password  # Can be empty for IRSA
KC_TRANSACTION_XA_ENABLED: false
KC_HEALTH_ENABLED: true
KC_METRICS_ENABLED: true
```

### IRSA Configuration
```yaml
KEYCLOAK_DATABASE_HOST: aurora.rds.domain
KEYCLOAK_JDBC_PARAMS: wrapperPlugins=iam&ssl=true&sslmode=require
KEYCLOAK_DATABASE_PASSWORD: ""  # Empty for IAM auth
```

## Testing Strategy
- **Local PostgreSQL**: Tests basic connectivity with AWS wrapper and with standard postgres driver
- **AWS Aurora + IRSA**: Tests IAM authentication in AWS environment
- **Multi-architecture**: Builds for linux/amd64 and linux/arm64
- **Integration Tests**: Python-based Keycloak admin API tests

## Known Constraints & Design Decisions

### Quay Images Runtime Configuration
- All necessary configuration variables (KC_DB_DRIVER, KC_TRANSACTION_XA_ENABLED, etc.) must be set via environment variables

### Bitnami Legacy Migration
- Bitnami stopped publishing to Docker Hub (Aug 2025)
- Using `bitnamilegacy` repository for continued support
- Recommending migration to Quay-based images

## Common Operations

### Building Images
```bash
# Build Quay image for version 26
cd keycloak-26
docker build \
  --build-arg BASE_IMAGE_NAME="$(yq e '.sources.quay.image.repository' bases.yml | cut -d@ -f1)" \
  --build-arg BASE_IMAGE_TAG="$(yq e '.sources.quay.image.tag' bases.yml | cut -d@ -f1)" \
  --build-arg BASE_IMAGE_DIGEST="$(yq e '.sources.quay.image.tag' bases.yml | cut -d@ -f2)" \
  -f Dockerfile.quay -t camunda/keycloak:local-quay-26 .
```

### Testing Locally
```bash
# Test Bitnami 26+ with native KC_* variables
COMPOSE_KEYCLOAK_IMAGE=camunda/keycloak:local-bitnami-26 \
docker-compose up -d

# Test Bitnami <26 with legacy KEYCLOAK_* variables
COMPOSE_KEYCLOAK_IMAGE=camunda/keycloak:local-bitnami-25 \
docker-compose -f docker-compose.bitnamiold.yml up -d

# Test Quay with runtime AWS wrapper configuration
COMPOSE_KEYCLOAK_IMAGE=camunda/keycloak:local-quay-26 \
docker-compose -f docker-compose.quay.yml up -d

# Test with IRSA configuration (will fail without real AWS RDS)
KC_DB_DRIVER=software.amazon.jdbc.Driver \
KC_TRANSACTION_XA_ENABLED=false \
KEYCLOAK_DATABASE_HOST=test-rds.aws.example.com \
KEYCLOAK_DATABASE_NAME=testdb \
KEYCLOAK_JDBC_PARAMS="wrapperPlugins=iam" \
docker-compose -f docker-compose.quay.yml config
```

## File Structure Context
- `keycloak-*/`: Version-specific directories with Dockerfiles and base configurations
- `bases.yml`: Contains base image references with digest pinning
- `.github/workflows/build-images.yml`: CI/CD pipeline with matrix strategy
- `.github/scripts/integration/`: Python-based integration tests
- `docker-compose.yml`: For Bitnami 26+ with native KC_* variables
- `docker-compose.bitnamiold.yml`: For Bitnami <26 with legacy KEYCLOAK_* variables
- `docker-compose.quay.yml`: For Quay-based images

## Current Development Focus
The repository is actively transitioning to recommend Quay-based images as the primary solution while maintaining backward compatibility with Bitnami-based images for existing users.
