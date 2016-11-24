---
layout: default
deployDoc: true
---

## Sock Shop  Docker Compose & Weave

The Weave Demo application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file.

### Networking

In this version we create several isolated networks using the [Weave Docker plugin](https://www.weave.works/docs/net/latest/plugin/) and use Weave's DNS support.

### Pre-requisites

- Install [Docker](https://www.docker.com/products/overview)
- Install [Weave Scope](https://www.weave.works/install-weave-scope/)
- Install [Weave Net](https://www.weave.works/install-weave-net/)

### *(Optional)* Launch Weave Scope or Weave Cloud

Weave Scope (local instance)

    scope launch

Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    scope launch --service-token=<token>

### Pre-reqs

<!-- deploy-test-start pre-install -->

    curl -L git.io/weave -o /usr/local/bin/weave
    chmod a+x /usr/local/bin/weave

<!-- deploy-test-end -->
<!-- deploy-test-hidden pre-install 

    pip install docker-compose

-->
### Provision infrastructure

<!-- deploy-test-start create-infrastructure -->

    weave launch
    docker-compose up -d

<!-- deploy-test-end -->

<!-- deploy-test-hidden create-infrastructure 
    docker run -td -\-name healthcheck andrius/alpine-ruby /bin/sh 
    docker network connect dockercomposeweave_secure healthcheck
    docker network connect dockercomposeweave_internal healthcheck
    docker network connect dockercomposeweave_external healthcheck
    docker network connect dockercomposeweave_backoffice healthcheck
    docker cp /repo/deploy/healthcheck.rb healthcheck:/healthcheck.rb
-->   
### Run tests

There's a load test provided as a service in this compose file. For more information see [Load Test](#loadtest).  
It will run when the compose is started up, after a delay of 60s. This is a load test provided to simulate user traffic to the application.
This will send some traffic to the application, which will form the connection graph that you view in Scope or Weave Cloud. 

<!-- deploy-test-hidden run-tests

    docker exec -t healthcheck ruby /healthcheck.rb -s user,catalogue,queue-master,cart,shipping,payment,orders -d 120
    if [ $? -ne 0 ]; then 
        docker rm -f healthcheck 
        exit 1; 
    fi
    docker rm -f healthcheck 

-->


### Cleaning up

<!-- deploy-test-start destroy-infrastructure -->

    docker-compose down
    weave stop
   
<!-- deploy-test-end -->
