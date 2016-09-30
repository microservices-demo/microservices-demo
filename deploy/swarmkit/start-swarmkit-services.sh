#!/bin/bash
set -e
set -o pipefail

function usage() {
    echo "usage: $(basename $0) [cleanup]"
    echo "  When cleanup option is provided, the script will remove previously initiated services"
}

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

cleanup_services() {
    for srvc in front-end catalogue catalogue-db user user-db cart cart-db orders orders-db shipping payment
    do
      docker service rm $srvc
    done

}

if ! command_exists "docker" ; then
    echo "Please ensure that docker command is on the \$PATH"
    exit 1
fi

if [ "$1" == "cleanup" ]; then
    echo "Cleaning up services"
    cleanup_services
    exit 0;
fi

if [ "$1" == "help" ]; then 
    usage
    exit 0
fi

echo "Creating front-end service"
docker service create \
       --publish 8079 \
       --mode global \
       --name front-end weaveworksdemos/front-end:latest

echo "Creating catalogue service"
docker service create \
       --name catalogue \
       --network ingress \
       weaveworksdemos/catalogue:latest

echo "Creating catalogue-db service"
docker service create \
       --name catalogue-db \
       --network ingress \
        --env "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" \
        --env "MYSQL_DATABASE=socksdb" \
        --env "MYSQL_ALLOW_EMPTY_PASSWORD=true" \
       weaveworksdemos/catalogue-db

echo "Creating user service"
docker service create \
       --name user \
       --network ingress \
       weaveworksdemos/user:latest

echo "Creating user-db service"
docker service create \
       --name user-db \
       --network ingress \
       weaveworksdemos/user-db:latest


echo "Creating cart service"
docker service create \
       --name cart \
       --network ingress \
       weaveworksdemos/cart:latest


echo "Creating cart-db service"
docker service create \
       --name cart-db \
       --network ingress \
       mongo


echo "Creating orders service"
docker service create \
       --name orders \
       --network ingress \
       weaveworksdemos/orders:latest

echo "Creating orders-db service"
docker service create \
       --name orders-db \
       --network ingress \
       mongo

echo "Creating shipping service"
docker service create \
       --name shipping \
       --network ingress \
       weaveworksdemos/shipping:latest

echo "Creating payment service"
docker service create \
       --name payment \
       --network ingress \
       weaveworksdemos/payment:latest
