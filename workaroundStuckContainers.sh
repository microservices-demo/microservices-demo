#!/usr/bin/env bash
#Removes stuck containers. Workaround for "stuck" docker bug.

if [ "$#" -ne 1 ] ; then
  echo "Usage: $0 [docker-machine VM name]" >&2
  exit 1
fi

docker-machine ssh $1 "docker ps -a --no-trunc | grep 'Removal In Progress' | awk '{print \$1}' | xargs -I {} sudo rm -rv /var/lib/docker/containers/{}; sudo /etc/init.d/docker restart"