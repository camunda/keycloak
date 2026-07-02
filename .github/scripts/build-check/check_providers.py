#!/usr/bin/env python3
import sys
import subprocess
import argparse

# Required AWS components that must be present in all Keycloak images.
# Each entry is a group of acceptable names; at least one member must be present.
# The AWS SDK renamed its synchronous HTTP client module `apache-client` ->
# `apache5-client` (Apache HTTP 5.x) in newer releases, so both names are accepted.
REQUIRED_AWS_COMPONENTS = [
    ["aws-advanced-jdbc-wrapper"],
    ["sts"],
    ["apache-client", "apache5-client"],
]

# Components that must NOT ship in the Quay optimized providers directory.
# The AWS SDK pulls in its own (older) Netty through netty-nio-client; if it lands in
# /opt/keycloak/providers it shadows Keycloak's bundled, Vert.x-aligned Netty and breaks
# HTTP/2 cleartext (H2C) upgrades at runtime with a NoSuchMethodError.
# See https://github.com/camunda/camunda-deployment-references/issues/2809
FORBIDDEN_QUAY_PROVIDERS = [
    "netty"
]


def check_required_components(output, suffix=""):
    """Return True if every required component group has a member present in output."""
    all_found = True
    for aliases in REQUIRED_AWS_COMPONENTS:
        present = next((alias for alias in aliases if alias in output), None)
        if present is not None:
            print(f"✅ {present} found{suffix}")
        else:
            print(f"❌ {' / '.join(aliases)} not found{suffix}")
            all_found = False
    return all_found

def run_docker_command(image_name, command):
    """Run a docker command and return the output"""
    try:
        cmd = ["docker", "run", "--entrypoint", "/bin/sh", image_name, "-c", " ".join(command)]
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running docker command: {e}")
        print(f"stderr: {e.stderr}")
        return None

def check_quay_providers(image_name):
    """Check providers directory for Quay images"""
    print("Checking Quay image providers...")

    # List providers directory
    output = run_docker_command(image_name, ["ls", "/opt/keycloak/providers/"])
    if output is None:
        return False

    print(f"Providers directory contents:\n{output}")

    all_found = check_required_components(output)

    # Ensure no conflicting components leaked into the providers directory
    for component in FORBIDDEN_QUAY_PROVIDERS:
        if component in output:
            print(f"❌ forbidden component '{component}' found in providers (must be removed)")
            all_found = False
        else:
            print(f"✅ {component} correctly absent")

    return all_found

def check_bitnami_config(image_name):
    """Check configuration for Bitnami images using show-config"""
    print("Checking Bitnami image configuration...")

    # Run show-config
    output = run_docker_command(image_name, ["/opt/bitnami/keycloak/bin/kc.sh", "show-config"])
    if output is None:
        return False

    print(f"Keycloak configuration:\n{output}")

    return check_required_components(output, " in config")

def main():
    parser = argparse.ArgumentParser(description='Check Keycloak image providers/configuration')
    parser.add_argument('image_name', help='Docker image name to check')
    parser.add_argument('image_type', choices=['quay', 'bitnami'], help='Type of image (quay or bitnami)')

    args = parser.parse_args()

    if args.image_type == 'quay':
        success = check_quay_providers(args.image_name)
    else:
        success = check_bitnami_config(args.image_name)

    if success:
        print(f"✅ Provider/config check passed for {args.image_type} image")
        sys.exit(0)
    else:
        print(f"❌ Provider/config check failed for {args.image_type} image (missing required or forbidden component present)")
        sys.exit(1)

if __name__ == "__main__":
    main()
