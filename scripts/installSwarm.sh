#!/bin/sh +x
#
# Handy utility for creating a Swarm environment using Docker Machine
#
#######################################################################
CMD="${1}"
COUNT="${2:-1}"
DRIVER="${3:-virtualbox}"
do_checks() {
  if [ ! `command -v docker-machine` ]; then
    echo "Docker Machine is not found!"
    exit 0
  fi
  # check for docker
  if [ ! `command -v docker` ]; then
    echo "Docker is not found!"
    exit 0
  fi
  return 1
}
do_create() {
  do_checks
  KEYSTORE_NAME=`docker-machine ls --format="{{.Name}}" --filter="name=swarm-keystore"`

  if [ "$DRIVER" == "AWS" ]; then
    echo "Installing Swarm on AWS..."
    if [ ! `command -v aws` ]; then
      echo "AWS command line tools not found."
      exit 0
    fi

    #Set up Security Group in AWS

    group_name="docker-networking"
    aws ec2 create-security-group --group-name ${group_name} --description "A Security Group for Docker Networking"
    # Permit SSH, required for Docker Machine
    aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 22 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 2376 --cidr 0.0.0.0/0
    # Permit Consul HTTP API
    aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 8500 --cidr 0.0.0.0/0
    # Weave 
    aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 6783 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol udp --port 6783 --cidr 0.0.0.0/0

    CREATE_ARGS="--driver amazonec2 --amazonec2-instance-type=t2.medium --amazonec2-vpc-id=vpc-a7d209c0 --amazonec2-zone=d --amazonec2-security-group ${group_name}"
    ETHERNET="eth0"
  else
    CREATE_ARGS="--driver virtualbox"
    ETHERNET="eth1"
  fi

  if [ -z "$KEYSTORE_NAME" ]; then
    # Create the machine that'll be used for config
    # and coordination by the Swarm master & members.
    # docker-machine create -d virtualbox swarm-keystore
    # Install on AWS.
    docker-machine create $CREATE_ARGS swarm-keystore
    echo "Docker Machine 'swarm-keystore' instance created!"
    # Check we have a working Docker host, and exit if all is not
    # well. Better to find out now than later...
    eval $(docker-machine env swarm-keystore)
    RET=`docker info | grep -m1 -o 'Server Version: .*' `
    RET="${RET#Server Version: }"
    if [ -z "$RET" ]; then
      echo "'docker info' returned an error"
      exit 0
    fi
  fi
  # Launch an Hashicorp Consul key/value store instance.
  # Subsequent launches will reference this store.
  docker run -d \
    --restart=unless-stopped \
    -p "8500:8500" \
    -h "consul" \
    --name=consul \
    progrium/consul -server -bootstrap
  # Define an env var for subsequent repeated use (avoiding
  # the ongoing overhead of talking to each machine).
  KEYSTORE_IP=$(docker-machine ip swarm-keystore)
  # Create the Swarm master node
  docker-machine create $CREATE_ARGS \
    --swarm \
    --swarm-master \
    --swarm-discovery="consul://${KEYSTORE_IP}:8500" \
    --engine-opt="cluster-store=consul://${KEYSTORE_IP}:8500" \
    --engine-opt="cluster-advertise=${ETHERNET}:2376" \
    swarm-master
  eval $(docker-machine env --swarm swarm-master)
  # Create multiple Swarm slave nodes, per the user input
  # argument, by calling "do_add" function
  do_add
  # Check that the Swarm is created...
  # This will provide visual output to the use
  RET=`docker info | grep -m1 -o 'Server Version: .*' `
  RET="${RET#Server Version: }"
  eval "$(docker-machine env --swarm swarm-master)"
  exit 1
}
do_add() {
  do_checks
  # Define an env var for subsequent repeated use (avoiding
  # the ongoing overhead of talking to each machine).
  KEYSTORE_IP=$(docker-machine ip swarm-keystore)
  if [ -z "$KEYSTORE_IP" ]; then
    echo "ERROR: 'swarm-keystore' does not exist"
    exit 1
  fi
  # Define two variables; one to loop and one for the name
  local counter=0
  local count=0
  # Now run the while loop... check each iteration to see
  # if the slave name already exists, and skip that one if
  # it does...
  while [[ $counter < $COUNT ]]; do

    EXISTS=`docker-machine ls --format="{{.Name}}" --filter="name=swarm-node-${count}"`
    if [ -z "$EXISTS" ]; then
      echo "Swarm node 'swarm-node-${count}' does not exist"
      docker-machine create $CREATE_ARGS \
        --swarm \
        --swarm-discovery="consul://${KEYSTORE_IP}:8500" \
        --engine-opt="cluster-store=consul://${KEYSTORE_IP}:8500" \
        --engine-opt="cluster-advertise=${ETHERNET}:2376" \
        swarm-node-${count}
      counter=$((counter + 1))
    else
      echo "Swarm node 'swarm-node-${count}' DOES exist!"
    fi
    count=$((count + 1))
  done
  # Output the current state of the Swarm
  docker-machine ls --filter="swarm=swarm-master"
  exit 1
}
do_destroy() {
  SWARM=`docker-machine ls --filter="swarm=swarm-master" --format="{{.Name}}"`
  for MACHINE_NAME in ${SWARM}
  do
    echo "Removing $MACHINE_NAME..."
    docker-machine stop $MACHINE_NAME && docker-machine rm -y $MACHINE_NAME
  done
  echo "Removing swarm-keystore..."
  docker-machine stop swarm-keystore && docker-machine rm -y swarm-keystore
  exit 0
}
do_list() {
  do_checks
  # Define an env var for subsequent repeated use (avoiding
  # the ongoing overhead of talking to each machine).
  KEYSTORE_NAME=`docker-machine ls --format="{{.Name}}" --filter="name=swarm-keystore"`
  if [ -z "$KEYSTORE_NAME" ]; then
    echo "Expected hostname 'swarm-keystore' does not exist!"
    exit 0
  fi
  # The keystore IP must be available
  KEYSTORE_IP=$(docker-machine ip swarm-keystore)
  eval $(docker-machine env swarm-keystore)
  LIST=`docker run swarm list consul://${KEYSTORE_IP}:8500`
  echo "$LIST"

  exit 1
}
do_usage() {
  cat >&2 <<EOF
Usage:
  swarm [ create [ count ] | add [ count ] | destroy | list | --help ]
EOF
  exit 0
}
case "$CMD" in
  create)
    do_create
    ;;
  add)
    do_add
    ;;
  destroy)
    do_destroy
    ;;
  list)
    do_list
    ;;
  *)
    do_usage
    ;;
esac
