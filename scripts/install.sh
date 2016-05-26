#!/bin/sh
#
# Install docker-machine cluster, swarm, weave and scope
#
#####################################################################
ARGS="$@"
COMMAND="${1}"
SCRIPT_DIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`
MASTER_NODE_NAME="${2}"
export VERSION=${SCOPE_VERSION:-latest}
do_checks() {
  # check for docker-machine
  if [ ! `command -v docker-machine` ]; then
    echo "Docker Machine is not found!"
    exit 0
  fi
  # check for docker
  if [ ! `command -v docker` ]; then
    echo "Docker is not found!"
    exit 0
  fi
}
do_launch() {
  do_checks
  echo "Creating docker-machines and installing swarm"
  $SCRIPT_DIR/installSwarm.sh create 2

  echo "Installing weave"
  $SCRIPT_DIR/installWeave.sh launch

  echo "Installing scope"
  $SCRIPT_DIR/installScope.sh launch

  exit 0
}
do_stop() {
  do_checks

  echo "Stopping scope"
  $SCRIPT_DIR/installScope.sh stop

  echo "Stopping weave"
  $SCRIPT_DIR/installWeave.sh stop

  exit 0
}
do_destroy() {
  do_checks

  echo "Destroying swarm"
  $SCRIPT_DIR/installSwarm.sh destroy

  exit 0
}
do_usage() {
    cat >&2 <<EOF
Usage:
  ${SCRIPT_NAME} [ launch | stop | destroy ] OPTIONS
Description:
  Installs swarm, weave and scope on a docker-machine VM
EOF
  exit 1
}
case "$COMMAND" in
  launch)
    do_launch
    ;;
  stop)
    do_stop
    ;;
  destroy)
    do_destroy
    ;;
  *)
    do_usage
    ;;
esac
