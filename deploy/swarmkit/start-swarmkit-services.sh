#!/bin/bash

function usage() {
    echo "usage: $(basename $0) [cleanup]"
    echo "  When cleanup option is provided, the script will remove previously initiated services"
}

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

exit_on_failure() {
    if [ $? -ne 0 ]; then
        echo "Command failed"
        exit 1;
    fi
}

cleanup_services() {
    docker service rm front-end
    docker service rm catalogue
    docker service rm catalogue-db
    docker service rm user
    docker service rm user-db
    docker service rm cart
    docker service rm cart-db
    docker service rm orders
    docker service rm orders-db
    docker service rm shipping
    docker service rm payment
}

if ! command_exists "docker" ; then
    echo "Please ensure that docker cermand is on the \$PATH"
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
       --name front-end --env "reschedule=on-node-failure" weaveworksdemos/front-end:latest

exit_on_failure

echo "Creating catalogue service"
docker service create \
       --name catalogue \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/catalogue:latest
exit_on_failure

echo "Creating catalogue-db service"
docker service create \
       --name catalogue-db \
       --network ingress \
        --env "reschedule=on-node-failure" \
        --env "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" \
        --env "MYSQL_DATABASE=socksdb" \
        --env "MYSQL_ALLOW_EMPTY_PASSWORD=true" \
       weaveworksdemos/catalogue-db
exit_on_failure

echo "Creating user service"
docker service create \
       --name user \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/user:latest
exit_on_failure

echo "Creating user-db service"
docker service create \
       --name user-db \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/user-db:latest
exit_on_failure


echo "Creating cart service"
docker service create \
       --name cart \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/cart:latest
exit_on_failure


echo "Creating cart-db service"
docker service create \
       --name cart-db \
       --network ingress \
       --env "reschedule=on-node-failure" mongo
exit_on_failure


echo "Creating orders service"
docker service create \
       --name orders \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/orders:latest
exit_on_failure

echo "Creating orders-db service"
docker service create \
       --name orders-db \
       --network ingress \
       --env "reschedule=on-node-failure" mongo
exit_on_failure

echo "Creating shipping service"
docker service create \
       --name shipping \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/shipping:latest
exit_on_failure

echo "Creating payment service"
docker service create \
       --name payment \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/payment:latest
exit_on_failure
