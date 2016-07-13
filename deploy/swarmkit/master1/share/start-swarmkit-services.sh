#!/bin/bash

# if [ -z ${SWARM_SOCKET} ]; then
#     echo "SWARM_SOCKET environment variable is unset."
#     exit 1
# fi

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
    # docker service rm edge-router
    docker service rm catalogue
    docker service rm accounts
    docker service rm accounts-db
    docker service rm cart
    docker service rm cart-db
    docker service rm orders
    docker service rm orders-db
    docker service rm shipping
    # docker service rm queue-master
    # docker service rm rabbitmq
    docker service rm payment
    docker service rm login
    #docker service rm weave-scope
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

echo "Creating front-end service"
docker service create \
       --network ingress \
       --publish 8097:80 \
       --name front-end --env "reschedule=on-node-failure" weaveworksdemos/front-end:latest

exit_on_failure

# echo "Creating edge-router service"
# docker service create \
#        --name edge-router \
#        --network ingress \
#        --publish 80 \
#        --env "reschedule=on-node-failure" weaveworksdemos/edge-router:latest

# exit_on_failure

echo "Creating catalogue service"
docker service create \
       --name catalogue \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/catalogue:latest
exit_on_failure


echo "Creating accounts service"
docker service create \
       --name accounts \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/accounts:latest
exit_on_failure

echo "Creating accounts-db service"
docker service create \
       --name accounts-db \
       --network ingress \
       --env "reschedule=on-node-failure" mongo
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

# echo "Creating queue-master service"
# docker service create \
#        --name queue-master \
#        --network ingress \
#        --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
#        --env "reschedule=on-node-failure" weaveworksdemos/queue-master:latest
# exit_on_failure


# echo "Creating rabbitmq service"
# docker service create \
#        --name rabbitmq \
#        --network ingress \
#        --env "reschedule=on-node-failure" rabbitmq:3
# exit_on_failure

echo "Creating payment service"
docker service create \
       --name payment \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/payment:latest
exit_on_failure

echo "Creating login service"
docker service create \
       --name login \
       --network ingress \
       --env "reschedule=on-node-failure" weaveworksdemos/login:latest
exit_on_failure



echo "Creating weave scope service"
# docker service create \
#        --name weave-scope \
#        --network ingress weaveworks/scope:0.15
exit_on_failure

echo "Done"
