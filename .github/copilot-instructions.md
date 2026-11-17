# Camunda Keycloak Container Images - Repository Context

## Repository Purpose
This repository builds and maintains containerized Keycloak images for Camunda with two main variants:
- **Quay-based images** (`quay-*` tags): Official Keycloak from Quay.io with AWS JDBC wrapper and runtime configuration
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
- `docker-compose.yml`: For Bitnami-based images with runtime driver flexibility
- `docker-compose.quay.yml`: For Quay-based images with runtime AWS wrapper configuration

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
- The public `bitnamilegacy`-based images are no longer built
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
# Run from the repository root, not from keycloak-26
# Check the providers of the image (job test-base-image)
python3 .github/scripts/build-check/check_providers.py camunda/keycloak:local-quay-26 quay
# Keycloak 26 only: the JVM trust store has no distrusted root (job test-base-image)
! docker run --rm --entrypoint keytool camunda/keycloak:local-quay-26 -list -v -cacerts -storepass changeit \
  | grep -E '^Owner: CN=(emSign ECC Root CA - G3|AAA Certificate Services|emSign Root CA - G1|emSign Root CA - G2),'

# Test with local PostgreSQL (job test-postgres-integ on ubuntu-latest), in the PostgreSQL version of the Keycloak release
COMPOSE_POSTGRES_IMAGE="docker.io/postgres:$(curl -s https://raw.githubusercontent.com/keycloak/keycloak/release/26.0/pom.xml | awk -F'[><]' '/<postgresql.version>/{print $3}')" \
COMPOSE_KEYCLOAK_IMAGE=camunda/keycloak:local-quay-26 \
KEYCLOAK_JDBC_DRIVER=postgresql \
KC_DB_DRIVER=org.postgresql.Driver \
docker compose -f docker-compose.quay.yml up --wait --wait-timeout 300
pip install -r .github/scripts/integration/requirements.txt
python3 .github/scripts/integration/main.py
```

### Linting
- `lint / pre-commit`: the hooks of `.pre-commit-config.yaml`, with the `pre-commit` version that `.tool-versions` pins. Local run: `pre-commit run --all-files`.
- `lint / baseline`: the central hook list of camunda/infraex-common-config ([Baseline](https://github.com/camunda/infraex-common-config/blob/main/README.md#baseline)). Local run: clone that repository into `.infraex-common-config`, then run `pre-commit run --config .infraex-common-config/baseline/.pre-commit-config.yaml --all-files`. Do not stage that folder.
- `lint / renovate annotations`: each `# renovate:` annotation must extract exactly one dependency ([Version Annotations](https://github.com/camunda/infraex-common-config/blob/main/README.md#version-annotations)). Local run, with that clone and the Python module `json5`: `python3 .infraex-common-config/.github/workflows/scripts/check_renovate_annotations.py --preset .infraex-common-config/default.json5 --root .`.

## File Structure Context
- `keycloak-*/`: Version-specific directories with Dockerfiles and base configurations
- `bases.yml`: Contains base image references with digest pinning
- `.github/workflows/build-images.yml`: CI/CD pipeline with matrix strategy
- `.github/scripts/integration/`: Python-based integration tests
- `docker-compose*.yml`: Different compose files for different image types

## Current Development Focus
The repository is actively transitioning to recommend Quay-based images as the primary solution while maintaining backward compatibility with Bitnami-based images for existing users.
