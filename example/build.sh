#!/bin/bash -e

echo "Building on 'swarm-master':"
docker $(docker-machine config 'swarm-master') build -t app_web .
echo "Copying from 'swarm-master' to 'swarm-node-0' and 'swarm-node-1'"
docker $(docker-machine config 'swarm-master') save app_web \
  | tee \
    >(docker $(docker-machine config 'swarm-node-0') load) \
    >(docker $(docker-machine config 'swarm-node-1') load) \
  | cat > /dev/null
