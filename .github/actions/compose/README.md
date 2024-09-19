# Compose

## Description

Compose Wrapper


## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `compose_file` | <p>Name of the compose file</p> | `false` | `docker-compose.yml` |
| `project_name` | <p>Project name to allow running the same file multiple times</p> | `true` | `""` |
| `healthy_timeout` | <p>How long to wait until we consider the compose to be unhealthy</p> | `false` | `300` |
| `cwd` | <p>Current working directory</p> | `false` | `${{ github.workspace }}` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: camunda/keycloak/.github/actions/compose@main
  with:
    compose_file:
    # Name of the compose file
    #
    # Required: false
    # Default: docker-compose.yml

    project_name:
    # Project name to allow running the same file multiple times
    #
    # Required: true
    # Default: ""

    healthy_timeout:
    # How long to wait until we consider the compose to be unhealthy
    #
    # Required: false
    # Default: 300

    cwd:
    # Current working directory
    #
    # Required: false
    # Default: ${{ github.workspace }}
```
