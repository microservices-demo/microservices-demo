#!/bin/bash

set -uo pipefail

SCOPE_TOKEN=${1:-}

command -v jq &>/dev/null
if [ $? -ne 0 ]; then
    echo "jq is required, available here: https://github.com/stedolan/jq"
    exit 1
fi

scripts/setup1-infra.sh $SCOPE_TOKEN
scripts/setup2-containers.sh
scripts/setup3-showconf.sh $SCOPE_TOKEN
