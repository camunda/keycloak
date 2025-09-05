#!/usr/bin/env python3
import sys
import subprocess
import argparse

# Required AWS components that must be present in all Keycloak images
REQUIRED_AWS_COMPONENTS = [
    "aws-advanced-jdbc-wrapper",
    "sts",
    "apache-client"
]

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

    # Check for required components
    all_found = True
    for component in REQUIRED_AWS_COMPONENTS:
        if component in output:
            print(f"✅ {component} found")
        else:
            print(f"❌ {component} not found")
            all_found = False

    return all_found

def check_bitnami_config(image_name):
    """Check configuration for Bitnami images using show-config"""
    print("Checking Bitnami image configuration...")

    # Run show-config
    output = run_docker_command(image_name, ["/opt/bitnami/keycloak/bin/kc.sh", "show-config"])
    if output is None:
        return False

    print(f"Keycloak configuration:\n{output}")

    # Check for required components in config
    all_found = True
    for component in REQUIRED_AWS_COMPONENTS:
        if component in output:
            print(f"✅ {component} found in config")
        else:
            print(f"❌ {component} not found in config")
            all_found = False

    return all_found

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
        print(f"✅ All required AWS components found in {args.image_type} image")
        sys.exit(0)
    else:
        print(f"❌ Some required AWS components missing in {args.image_type} image")
        sys.exit(1)

if __name__ == "__main__":
    main()
