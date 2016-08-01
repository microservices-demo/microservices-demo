#!/usr/bin/env bash
function connect {
  name=$1
  ancestor=$2
  networks=$3

  CID=$(docker ps -q -f ancestor=$ancestor)
  if [ $CID ]
  then
    # Go over the networks that we wish the container is connected to
    for network in $networks
    do
      # Get list of containers connected to $network
      CIDS=$(docker network inspect -f "{{.Containers}}" $network)
      if [[ ! $CIDS =~ $CID ]] # If the container is not yet in the list of containers connected to the network
      then
        # Connect container $CID to network $network
        docker network connect $network $CID
        echo "==> $name container successfully connected to network $network"
      fi
    done
  fi
}

while true
do
  connect front-end weaveworksdemos/front-end "secure internal external"
  connect orders weaveworksdemos/orders "internal secure backoffice"
  sleep 2
done
