#!/bin/bash
#
# Launch Scope correctly on all Docker Machines in the Swarm
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
  # check for scope
  if [ ! `command -v $SCRIPT_DIR/scope` ]; then
    echo "Scope script is not found!"
    exit 0
  fi
}
do_init() {
  # get all Docker Host URLs
  RUNNING_HOST_NAMES=($(docker-machine ls --filter="swarm=swarm-master" --format={{.Name}}))
  return 1
}
do_launch() {
  do_checks
  do_init
  echo "Launching Scope App on swarm-master..."
  eval $(docker-machine env swarm-master)
  RET=`VERSION=${VERSION} $SCRIPT_DIR/scope launch `
  SCOPE_MASTER=${RUNNING_HOST_NAMES[0]}
  SCOPE_SLAVES=${RUNNING_HOST_NAMES[*]:1}
  MASTER_NODE_IP=`docker-machine ip swarm-master`
  for MACHINE_NAME in ${SCOPE_SLAVES[*]}
  do
    echo "Launching Scope Probe on ${MACHINE_NAME}..."
    eval $(docker-machine env ${MACHINE_NAME})
    RET=`VERSION=${VERSION} $SCRIPT_DIR/scope launch --no-app ${MASTER_NODE_IP}`
  done
  exit 1
}
do_stop() {
  do_checks
  do_init
  for MACHINE_NAME in ${RUNNING_HOST_NAMES[*]}
  do
    echo "Stopping Scope on ${MACHINE_NAME}..."
    eval $(docker-machine env ${MACHINE_NAME})
    RET=`VERSION=${VERSION} $SCRIPT_DIR/scope stop`
  done
  exit 1
}
do_usage() {
    cat >&2 <<EOF
Usage:
  ${SCRIPT_NAME} [ launch [master-node-name] | status | stop ] OPTIONS
Description:
  Safely launches Scope on all running Docker Hosts
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
  *)
    do_usage
    ;;
esac
