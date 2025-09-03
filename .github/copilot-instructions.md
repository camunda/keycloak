# Camunda Keycloak Container Images - Repository Context

## Repository Purpose
This repository builds and maintains containerized Keycloak images for Camunda with three main variants:
- **Quay-based images** (`quay-*` tags): Official Keycloak from Quay.io with AWS JDBC wrapper pre-configured
- **Bitnami-based images** (`bitnami-*` tags): Based on Bitnami Legacy Keycloak
- **Enterprise images** (`bitnami-ee-*` tags): Premium enterprise-grade images

## Key Technical Architecture

### Image Variants & Driver Configuration
- **Quay images**: Have `KC_DB_DRIVER=software.amazon.jdbc.Driver` **fixed at build time** for optimal performance with Keycloak's optimized build process
- **Bitnami images**: Allow runtime driver configuration via `KC_DB_DRIVER` environment variable
- All images include AWS JDBC wrapper for IRSA (IAM Roles for Service Accounts) authentication

### AWS Integration Features
- **IRSA Support**: Enables passwordless database authentication using AWS IAM roles
- **AWS JDBC Wrapper**: Provides connection failover, monitoring, and IAM authentication
- **Connection Types**:
  - Local PostgreSQL: `jdbc:aws-wrapper:postgresql://postgres:5432/db`
  - AWS Aurora with IRSA: `jdbc:aws-wrapper:postgresql://aurora.domain:5432/db?wrapperPlugins=iam`

### Build System
- **Multi-stage Dockerfiles**: Separate build for dependencies (AWS wrapper, Identity theme)
- **Version Matrix**: Supports Keycloak versions 23, 24, 25, 26
- **CI/CD Pipeline**: Automated builds, tests (local + Aurora), and publishing to Docker Hub/Camunda registry

## Important Configuration Patterns

### Docker Compose Files
- `docker-compose.yml`: For Bitnami-based images with runtime driver flexibility
- `docker-compose.quay.yml`: For Quay-based images with fixed AWS wrapper driver

### Environment Variables (Quay images)
```yaml
KC_DB_URL: jdbc:aws-wrapper:postgresql://host:port/db?params
KC_DB_USERNAME: username
KC_DB_PASSWORD: password  # Can be empty for IRSA
# Note: KC_DB_DRIVER is pre-configured, don't override
```

### IRSA Configuration
```yaml
KEYCLOAK_DATABASE_HOST: aurora.rds.domain
KEYCLOAK_JDBC_PARAMS: wrapperPlugins=iam&ssl=true&sslmode=require
KEYCLOAK_DATABASE_PASSWORD: ""  # Empty for IAM auth
```

## Testing Strategy
- **Local PostgreSQL**: Tests basic connectivity with AWS wrapper
- **AWS Aurora + IRSA**: Tests IAM authentication in AWS environment
- **Multi-architecture**: Builds for linux/amd64 and linux/arm64
- **Integration Tests**: Python-based Keycloak admin API tests

## Known Constraints & Design Decisions

### Quay Images Optimization
- Driver is **fixed at build time** for maximum performance (Keycloak's optimized build)
- To change driver: modify Dockerfile and rebuild (not runtime configurable)
- Always use `aws-wrapper:postgresql` URLs even for local PostgreSQL

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
# Test with local PostgreSQL
COMPOSE_KEYCLOAK_IMAGE=camunda/keycloak:local-quay-26 \
docker-compose -f docker-compose.quay.yml up -d

# Test with IRSA configuration (will fail without real AWS RDS)
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
- `docker-compose*.yml`: Different compose files for different image types

## Current Development Focus
The repository is actively transitioning to recommend Quay-based images as the primary solution while maintaining backward compatibility with Bitnami-based images for existing users.
