#!/usr/bin/env bash
set -x

SCRIPT_DIR=`dirname "$0"`
CODE_DIR=$(cd $SCRIPT_DIR/../../sockshop; pwd)

if [[ "$OSTYPE" == "darwin"* ]]; then
    VM_STATUS=$(docker-machine status $DOCKER_MACHINE_NAME)
    if [[ $VM_STATUS == "Running" ]] ; then
        VM_DIR=/tmp/code
        docker-machine ssh $DOCKER_MACHINE_NAME sudo rm -rf $VM_DIR
        docker-machine ssh $DOCKER_MACHINE_NAME mkdir $VM_DIR
        docker-machine scp -r $CODE_DIR/. $DOCKER_MACHINE_NAME:$VM_DIR
        CODE_DIR=$VM_DIR
    else
        exit 3  # VM not exported or not running
    fi
fi

docker run --rm --name maven-test -v $CODE_DIR:/usr/src/mymaven -w /usr/src/mymaven maven:3.2-jdk-8 mvn test

exit $(echo $?)
