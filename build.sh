#!/usr/bin/env bash
#Usage: ./build.sh [ARGS]
# Where ARGS = name of the module you want to build. Default all.

DOCKER_GROUP=weaveworksdemos
TAG=latest

if [ -z "$@" ]
  then
    MODULES="accounts cart catalogue front-end login orders payment queue-master shipping worker edge-router"
else
    MODULES="$@"
fi
echo "Building module(s): $MODULES"

echo "Building java services"
./mvnw -DskipTests package
MVN_EXIT=$(echo $?)
if [[ "$MVN_EXIT" > 0 ]] ; then
    echo "Compilation failed with exit code $MVN_EXIT";
    exit 1;
fi

for module in ${MODULES}; do
    if [[ -n $(docker-machine ls -q | grep "swarm-master") ]] ; then
        echo "Building $module on swarm-master";
        docker $(docker-machine config 'swarm-master') build -t ${DOCKER_GROUP}/${module}:${TAG} ./${module};
    else
        echo "Building $module on $(docker-machine active)";
        docker build -t ${DOCKER_GROUP}/${module}:${TAG} ./${module};
    fi
    DOCKER_EXIT=$(echo $?);
    if [[ "$DOCKER_EXIT" > 0 ]] ; then
        echo "Docker build failed with exit code $DOCKER_EXIT";
    exit 1
    fi

    if [[ -n $(docker-machine ls -q | grep "swarm-node") ]] ; then
        echo "Copying $module from 'swarm-master' to 'swarm-node-0' and 'swarm-node-1'...";
        docker $(docker-machine config 'swarm-master') save ${DOCKER_GROUP}/${module}:${TAG} \
          | tee \
            >(docker $(docker-machine config 'swarm-node-0') load) \
            >(docker $(docker-machine config 'swarm-node-1') load) \
          | cat > /dev/null
    fi
done
