---
layout: default
deployDoc: true
---

## Sock Shop via Docker Swarm(Single-Node)

Please refer to the [new Docker Swarm introduction](http://container-solutions.com/hail-new-docker-swarm/)

### Blockers

Currently, new Docker Swarm does not support running containers in privileged mode.
Maybe it will be allowed in the future.
Please refer to the issue [1030](https://github.com/docker/swarmkit/issues/1030#issuecomment-232299819).
This prevents running Weave Scope in a normal way, since it needs privileged mode.
A work around exists documented [here](https://github.com/weaveworks/scope-global-swarm-service)

Running global plugins is not supported either.

### Pre-requisities

* Docker For Mac (limited to a single node)

### How-to using Docker For Mac

* Put your docker into the swarm mode
* Execute the services startup script
* Navigate to <a href="http://localhost" target="_blank">http://localhost</a> to verify that the demo works.

<!-- deploy-test-start pre-install -->

    docker swarm init 2>/dev/null
    sh ./start-swarmkit-services.sh

<!-- deploy-test-end -->

<!-- deploy-test-hidden create-infrastructure 
    docker service create -\-name healthcheck -\-network msnet andrius/alpine-ruby sleep 1200
    sleep 30
    ID=$(docker ps | grep healthcheck | awk '{print $1}')
    docker cp /repo/deploy/healthcheck.rb $ID:/healthcheck.rb
-->

### Run tests

There is a seperate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).  
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud. 

    docker run --rm --net host weaveworksdemos/load-test -d 60 -h localhost:30000 -c 3 -r 10

<!-- deploy-test-hidden run-tests 
    ID=$(docker ps | grep healthcheck | awk '{print $1}')
    docker exec $ID ruby /healthcheck.rb -s user,catalogue,cart,shipping,payment,orders -d 300 
    if [ $? -ne 0 ]; then 
        docker service rm healthcheck
        exit 1; 
    fi
    docker service rm healthcheck
-->

### Cleaning up

<!-- deploy-test-start destroy-infrastructure -->

    sh ./start-swarmkit-services.sh cleanup

<!-- deploy-test-end -->
