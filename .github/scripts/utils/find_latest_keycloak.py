
#!/usr/bin/env python3
"""
Script: find_latest_keycloak.py
Description: Finds the latest version of Keycloak from folders prefixed with "keycloak-" in a specified directory.
Usage: python find_latest_keycloak.py /path/to/directory
"""


import os
import sys

def extract_version(folder_name):
    return tuple(map(int, folder_name.split('-')[1].split('.')))

def find_latest_keycloak_version(directory):
    keycloak_folders = [folder for folder in os.listdir(directory) if folder.startswith("keycloak-") and os.path.isdir(os.path.join(directory, folder))]

    if not keycloak_folders:
        return None

    latest_version = max(keycloak_folders, key=extract_version)

    return latest_version

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python find_latest_keycloak.py /path/to/dor")
        sys.exit(1)

    directory_path = sys.argv[1]

    if not os.path.exists(directory_path):
        print(f"Speficied directory does not exists: {directory_path}")
        sys.exit(1)

    latest_version = find_latest_keycloak_version(directory_path)

    if latest_version:
        print(f"{latest_version.replace('keycloak-', '')}")
    else:
        print(f"No keycloak folders found in: {directory_path}")
        exit(1)
