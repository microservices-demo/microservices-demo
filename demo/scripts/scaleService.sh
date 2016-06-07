#!/usr/bin/env bash
#Scales a service

if [ "$#" -ne 2 ] ; then
  echo "Usage: $0 [service name] [num instances]. E.g. $0 catalogue 3" >&2
  exit 1
fi

docker-compose scale $1=$2

docker-compose logs -f $1