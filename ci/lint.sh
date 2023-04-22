#!/bin/bash

REPO=$(git rev-parse --show-toplevel)

pushd "$REPO" >/dev/null || exit

SOURCES=(rcmpy/configs rcmpy/includes rcmpy/rcmpy.yaml)
SOURCES+=(.github/workflows)

yamllint -v
set -x && yamllint -f github -s "${SOURCES[@]}" && set +x

popd >/dev/null || exit

echo "Script completed successfully."
