#!/usr/bin/env bash
#Kills a chosen service

if [ "$#" -ne 1 ] ; then
  echo "Usage: $0 [service name]. E.g. $0 shipping" >&2
  exit 1
fi

docker-compose exec $1 kill 1

docker-compose logs -f $1