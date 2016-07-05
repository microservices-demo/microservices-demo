#!/bin/bash
#
# Launch Scope correctly on all Kubernetes nodes
#
#####################################################################
ARGS="$@"
COMMAND="${1}"
SCRIPT_DIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`
MASTER_NODE_NAME="${2}"
export VERSION=${SCOPE_VERSION:-latest}

#On each node
sudo wget -O /usr/local/bin/scope https://git.io/scope
sudo chmod a+x /usr/local/bin/scope
sudo scope launch --no-app

#on Master
sudo wget -O /usr/local/bin/scope https://git.io/scope
sudo chmod a+x /usr/local/bin/scope
sudo scope launch
