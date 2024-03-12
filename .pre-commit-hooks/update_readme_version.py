#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import re
import fileinput

def main(argv: Sequence[str] | None = None) -> int:
    # Get the latest version of Keycloak from the find_latest_keycloak.py script
    latest_version_process = subprocess.run(["/usr/bin/env", "python3", ".github/scripts/utils/find_latest_keycloak.py", "."], stdout=subprocess.PIPE)
    latest_version = latest_version_process.stdout.decode().strip()

    # Check if the latest version is present in the readme.md file
    readme_path = "README.md"
    with open(readme_path, "r") as readme_file:
        readme_content = readme_file.read()
        if re.search(f"docker.io/camunda/keycloak:{latest_version}", readme_content) is None:
            print(f"Error: The file {readme_path} does not contain the latest version of Keycloak (docker.io/camunda/keycloak:{latest_version})")
            # Update the version in the readme.md file
            with fileinput.FileInput(readme_path, inplace=True) as file:
                for line in file:
                    print(re.sub(r"docker.io/camunda/keycloak:\d+", f"docker.io/camunda/keycloak:{latest_version}", line), end="")
            return 1

        # Everything is OK
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
