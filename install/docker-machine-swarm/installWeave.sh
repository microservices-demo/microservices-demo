#!/bin/bash +x
#
# Quickly launch Weave correctly on a Docker Swarm
#
#####################################################################

set -ox

ARGS="$@"
COMMAND="${1}"
SCRIPT_NAME=`basename "$0"`
SCRIPT_DIR=`dirname "$0"`

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

  # Check for the weave binary
  if [ `command -v weave` ]; then
    WEAVE_BINARY=`command -v weave`
  else
        WEAVE_BINARY=`command -v $SCRIPT_DIR/weave`
  fi
  if [ ! $WEAVE_BINARY ]; then
    echo "Weave binary is not found!"
    exit 0
  fi

  return 1
}

do_init() {
  # get the swarm masters
  SWARM_MASTER_NAME=`docker-machine ls --filter="state=running" | grep '(master)' | awk '{ print $1}'`
  # echo SWARM_MASTER_NAME=$SWARM_MASTER_NAME

  SWARM_MASTER_IP=`docker-machine ip $SWARM_MASTER_NAME`
  # echo SWARM_MASTER_IP=$SWARM_MASTER_IP

  SWARM_MASTER_URL=`docker-machine url $SWARM_MASTER_NAME`
  # echo SWARM_MASTER_URL=$SWARM_MASTER_URL

  eval $(docker-machine env --swarm $SWARM_MASTER_NAME)
#  DOCKER_HOST=$SWARM_MASTER_URL
  # echo "DOCKER_HOST=$DOCKER_HOST"

  # get all swarm agent Docker Host URLs
  SWARM_SLAVES=`docker-machine ls --filter "state=running" --filter="swarm=$SWARM_MASTER_NAME" --format={{.URL}}`
  # echo SWARM_SLAVES=$SWARM_SLAVES

  return 1
}

do_launch() {
  do_checks
  do_init

  echo "Launching Weave on Swarm Master..."
  #echo ">>> DOCKER_HOST=$SWARM_MASTER_URL weave launch-plugin"
  RET=`DOCKER_HOST=$SWARM_MASTER_URL $WEAVE_BINARY launch-router`
  RET=`DOCKER_HOST=$SWARM_MASTER_URL $WEAVE_BINARY launch-plugin --no-multicast-route`
  #echo ">>> DOCKER_HOST=$SWARM_MASTER_URL weave launch-router"
  # echo ">>> DOCKER_HOST=$SWARM_MASTER_URL weave launch-proxy"
  # RET=`DOCKER_HOST=$SWARM_HOST weave launch-plugin`

  for SWARM_HOST in $SWARM_SLAVES
  do
    if [ "$SWARM_MASTER_URL" == "$SWARM_HOST" ]; then
      echo "..."

    else
      echo ""
      echo "Launching Weave on Swarm Slave $SWARM_HOST..."

      echo ">>> DOCKER_HOST=$SWARM_HOST weave launch-router $SWARM_MASTER_IP"
      RET=`DOCKER_HOST=$SWARM_HOST $WEAVE_BINARY launch-router $SWARM_MASTER_IP`

      echo ">>> DOCKER_HOST=$SWARM_HOST weave launch-plugin"
      RET=`DOCKER_HOST=$SWARM_HOST $WEAVE_BINARY launch-plugin --no-multicast-route`

      #echo ">>> DOCKER_HOST=$SWARM_HOST weave launch-proxy"
      #RET=`DOCKER_HOST=$SWARM_HOST weave launch-proxy`
    fi
  done

  # echo "RET=$RET"
  exit 1
}

do_stop() {
  do_checks
  do_init

  for SWARM_HOST in $SWARM_SLAVES
  do
    echo "Stopping Weave on Swarm Host $SWARM_HOST..."
    #echo ">>> DOCKER_HOST=$SWARM_HOST weave stop"
    RET=`DOCKER_HOST=$SWARM_HOST $WEAVE_BINARY stop`
  done

  #echo "RET=$RET"
  exit 1
}

do_usage() {
    cat >&2 <<EOF
Usage:
  ${SCRIPT_NAME} [ launch | stop ] OPTIONS

Options:
  ${SCRIPT_NAME} launch [ --no-plugin | --no-proxy ]
  --no-plugin     Do not launch the plugin
  --no-proxy      Do not launch the proxy

Description:
  Safely launches Weave on Docker Swarm

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