#!/usr/bin/env bash

set -euxo pipefail

# Based on infraex-common-config's update-action-readmes-docker hook (v1.8.0).
# This action is internal, so its generated example must use a checkout-relative path.
USER_ID=$(id -u)
GROUP_ID=$(id -g)
REPO_URL=$(git config --get remote.origin.url)
REPO_URL_CLEAN=$(echo "$REPO_URL" | sed 's/.git$//')
OWNER_PROJECT=$(echo "$REPO_URL_CLEAN" | awk -F'[:/]' '{print $(NF-1)"/"$NF}')
DOC_ACTION_VERSION=${DOC_ACTION_VERSION:-main}
TOP_ACTION_DIR=".github/actions"
INTERNAL_ACTION_DIR=".github/actions/observe-build-status"
ACTION_DOCS_VERSION="2.5.1"

docker run --rm \
    -e USER_ID="$USER_ID" \
    -e GROUP_ID="$GROUP_ID" \
    -e DOC_ACTION_VERSION="$DOC_ACTION_VERSION" \
    -e OWNER_PROJECT="$OWNER_PROJECT" \
    -e TOP_ACTION_DIR="$TOP_ACTION_DIR" \
    -e INTERNAL_ACTION_DIR="$INTERNAL_ACTION_DIR" \
    -e ACTION_DOCS_VERSION="$ACTION_DOCS_VERSION" \
    -v "$PWD":/workspace \
    -w /workspace \
    node:22 \
    bash -c '
        set -euxo pipefail
        npm install --global "action-docs@$ACTION_DOCS_VERSION"

        find "$TOP_ACTION_DIR" -name "*.yml" -o -name "*.yaml" | while read -r action_file; do
            action_dir=$(dirname "$action_file")
            action_dir_top=$(basename "$action_dir")
            echo "Updating README.md in $action_dir"
            action-docs -t 1 --no-banner -n -s "$action_file" > "$action_dir/README.md.tmp"

            # Ensure that only a single empty line is left at the end of the file.
            sed -e :a -e "/^\n*\$/{\$d;N;};/\n\$/ba" "$action_dir/README.md.tmp" > "$action_dir/README.md"

            if [ "$action_dir" = "$INTERNAL_ACTION_DIR" ]; then
                PROJECT_PATH="./$action_dir"
            elif [ "$TOP_ACTION_DIR" != "." ]; then
                PROJECT_PATH="$OWNER_PROJECT/$TOP_ACTION_DIR/$action_dir_top@$DOC_ACTION_VERSION"
            else
                PROJECT_PATH="$OWNER_PROJECT/$action_dir_top@$DOC_ACTION_VERSION"
            fi

            sed -i "s|\*\*\*PROJECT\*\*\*@\*\*\*VERSION\*\*\*|$PROJECT_PATH|g" "$action_dir/README.md"
            chown "$USER_ID:$GROUP_ID" "$action_dir/README.md"
            rm -f "$action_dir/README.md.tmp"
        done
    '
