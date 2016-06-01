#!/usr/bin/env bash
#Stops, removes, builds and starts a single docker-compose service/module.
#Usage: ./reload.sh [service]
# service = name of the module/service you want to rebuild and load

if [ "$#" -ne 1 ] || ! [ -d "$1" ]; then
  echo "Usage: $0 [service]" >&2
  exit 1
fi

eval $(docker-machine env --swarm swarm-master);
docker-compose stop $1;
docker-compose rm -f $1;
docker rmi weaveworksdemos/$1;
./build.sh $1;
eval $(docker-machine env --swarm swarm-master);
docker-compose up -d $1