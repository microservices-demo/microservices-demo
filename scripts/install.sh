#!/bin/bash
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
    exit 1
  fi
  # check for docker
  if [ ! `command -v docker` ]; then
    echo "Docker is not found!"
    exit 1
  fi
}
do_launch() {
  do_checks
  case "$COMMAND" in
    launch)
      echo "Creating docker-machines and installing swarm Locally"
      $SCRIPT_DIR/installSwarm.sh create 2
      ;;
    launch-aws)
      echo "Creating docker-machines and installing swarm on AWS"
      $SCRIPT_DIR/installSwarm.sh create 2 amazonec2
  esac

  # Abort launch if swarm create failed
  if [ $? -ne 0 ]
  then
    echo "Error in upstream script"
    exit 1
  fi

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
  ${SCRIPT_NAME} [ launch | launch-aws | stop | destroy ] OPTIONS
Description:
  Installs swarm, weave and scope on a docker-machine VM
EOF
  exit 1
}
case "$COMMAND" in
  launch | launch-aws)
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
