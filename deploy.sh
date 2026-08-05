#!/usr/bin/env bash

set -e
set -o pipefail


BUILD_OPTS=''
if [[ "#${BUILD_PATH:-}" != "#" ]]; then
  BUILD_OPTS="${BUILD_OPTS} --from ${BUILD_PATH}"
fi
if [[ "#${CUSTOM_DOCKERFILE:-}" != "#" ]]; then
  BUILD_OPTS="${BUILD_OPTS} --dockerfile ${CUSTOM_DOCKERFILE}"
fi

if [[ "#${CREATE_ENV_SYMLINK:-}" != "#" ]]; then
  ENV_FILE_PATH="${ENV_FILEPATH}"
  ENV_SYMLINK_PATH="${BUILD_PATH:-.}/.env"

  ln -sf "$ENV_FILE_PATH"  "$ENV_SYMLINK_PATH"
fi

echo "Scrub files directory..."
FILES_PATH="${BUILD_PATH:-.}/web/sites/default/files/"
rm -rf $FILES_PATH/.??* $FILES_PATH/*

echo "Initialize Wodby CI..."
wodby ci init $INSTANCE_UUID \
  --provider "GitHub Actions" \
  --url "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"

echo "Build app containers..."
wodby ci build $BUILD_OPTS

echo "Pushing containers to registry..."
wodby ci release

echo "Trigger app deploy..."
wodby ci deploy
