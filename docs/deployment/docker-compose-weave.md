---
layout: default
---

## Sock Shop on Docker Compose & Weave

The Weave Demo application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file.

### Networking

In this version we create several isolated networks using the [Weave Docker plugin](https://www.weave.works/docs/net/latest/plugin/) and use Weave's DNS support.

### Pre-requisites

- Install Docker Compose
- Install [Weave Net](https://www.weave.works/install-weave-net/)
- (Optional) Install [Weave Scope](https://www.weave.works/install-weave-scope/)

<!-- deploy-test-start pre-install -->

    apt-get install -yq curl

    curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    curl -L git.io/weave -o /usr/local/bin/weave
    chmod a+x /usr/local/bin/weave

<!-- deploy-test-end -->


### Provision infrastructure

<!-- deploy-test-start create-infrastructure -->


    weave launch
    docker-compose up -d user-db user catalogue-db catalogue rabbitmq queue-master cart-db cart orders-db shipping payment orders front-end edge-router

<!-- deploy-test-end -->
    
### Run tests

Run the user similator load test. For more information see [Load Test](#loadtest)

<!-- deploy-test-start run-tests -->

    docker run --net dockercomposeweave_external --rm weaveworksdemos/load-test -d 60 -h edge-router -c 3 -r 10

<!-- deploy-test-end -->

### Cleaning up

<!-- deploy-test-start destroy-infrastructure -->

    docker-compose down
    weave stop
   
<!-- deploy-test-end -->

### Launch Weave Scope or Weave Cloud

Weave Scope (local instance)

    scope launch

Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    scope launch --service-token=<token>

### Load test

There's a load test provided to simulate user traffic to the application.

    docker run weaveworksdemos/load-test -h http://localhost/ -r 100 -c 2

This will send some traffic to the application, which will form the connection graph that you view in Scope or Weave Cloud.



