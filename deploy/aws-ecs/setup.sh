#!/bin/bash

set -euo pipefail

scripts/setup1-infra.sh
scripts/setup2-containers.sh
scripts/setup3-showconf.sh
