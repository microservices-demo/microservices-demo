#!/bin/bash

set -uo pipefail

SCOPE_TOKEN=${1:-}

if [ ! `command -v jq` ]; then
    echo "jq is required, available here: https://github.com/stedolan/jq"
    exit 1
fi

scripts/setup1-infra.sh $SCOPE_TOKEN
scripts/setup2-containers.sh
scripts/setup3-showconf.sh $SCOPE_TOKEN
