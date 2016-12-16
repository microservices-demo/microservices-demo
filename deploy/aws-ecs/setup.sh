#!/bin/bash

set -euo pipefail

SCOPE_TOKEN=${1:-}

scripts/setup1-infra.sh $SCOPE_TOKEN
scripts/setup2-containers.sh
scripts/setup3-showconf.sh $SCOPE_TOKEN
