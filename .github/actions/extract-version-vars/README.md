# Extract Version Variables

## Description

Extract and parse Keycloak version variables from matrix version string

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `keycloak_version` | <p>The Keycloak version string (e.g., "24-hub", "24-quay-optimized")</p> | `true` | `""` |
| `include_optimized` | <p>Whether to include is_optimized output (default: true)</p> | `false` | `true` |
| `include_image_type` | <p>Whether to include image_type output for provider checks (default: false)</p> | `false` | `false` |


## Outputs

| name | description |
| --- | --- |
| `version_name` | <p>Original version name from matrix</p> |
| `base_version` | <p>Base version number (e.g., "24")</p> |
| `base_type` | <p>Base type (e.g., "hub", "prem", "quay")</p> |
| `is_optimized` | <p>Whether this is an optimized build (true/false)</p> |
| `image_type` | <p>Image type for provider checks ("quay" or "bitnami")</p> |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: camunda/keycloak/.github/actions/extract-version-vars@main
  with:
    keycloak_version:
    # The Keycloak version string (e.g., "24-hub", "24-quay-optimized")
    #
    # Required: true
    # Default: ""

    include_optimized:
    # Whether to include is_optimized output (default: true)
    #
    # Required: false
    # Default: true

    include_image_type:
    # Whether to include image_type output for provider checks (default: false)
    #
    # Required: false
    # Default: false
```
