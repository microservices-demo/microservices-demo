#!/usr/bin/env bash


if [[ -z "$NUM_NODES" ]]; then
  NUM_NODES=2
fi

case $@ in
  up)
    vagrant up
    vagrant ssh swarm-master -c "docker swarm init --advertise-addr 10.0.0.10"
    TOKEN=$(vagrant ssh swarm-master -c "docker swarm join-token -q worker" | tr -d '\r')
    for i in $(seq $NUM_NODES); do
      vagrant ssh swarm-node$i -c 'docker swarm join --listen-addr 10.0.0.1'"'$i'"' --token '"'$TOKEN'"' 10.0.0.10'
    done
    vagrant ssh swarm-master -c "docker-compose -f /docker-swarm/docker-compose.yml pull"
    vagrant ssh swarm-master -c "docker-compose -f /docker-swarm/docker-compose.yml bundle -o dockerswarm.dab"
    vagrant ssh swarm-master -c "docker deploy dockerswarm"
    ;;
  down)
    vagrant destroy -f
    ;;
esac
