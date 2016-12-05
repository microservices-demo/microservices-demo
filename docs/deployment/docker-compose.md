---
layout: default
deployDoc: true
---

## Sock Shop via Docker Compose

The Sock Shop application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file.

### Networking

In this version we create a Docker network and DNS is achieved by using the internal Docker DNS, which reads network alias entries provided by docker-compose.

### Pre-requisites

- Install [Docker](https://www.docker.com/products/overview)
- Install [Docker Compose](https://docs.docker.com/compose/install/)
- *(Optional)* Install [Weave Scope](https://www.weave.works/install-weave-scope/)

```
git clone https://github.com/microservices-demo/microservices-demo 
cd microservices-demo
curl -sSL https://get.docker.com/ | sh
```
<!-- deploy-test-start pre-install -->

    apt-get install -yq python-pip
    pip install docker-compose

<!-- deploy-test-end -->


### *(Optional)* Launch Weave Scope or Weave Cloud

Weave Scope (local instance)

    sudo curl -L git.io/scope -o /usr/local/bin/scope
    sudo chmod a+x /usr/local/bin/scope
    scope launch

Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    sudo curl -L git.io/scope -o /usr/local/bin/scope
    sudo chmod a+x /usr/local/bin/scope
    scope launch --service-token=<token>

### Provision infrastructure

<!-- deploy-test-start pre-install -->

    docker-compose -f deploy/docker-compose/docker-compose.yml up -d 

<!-- deploy-test-end -->

<!-- deploy-test-hidden create-infrastructure 
    docker run -td -\-net=dockercompose_default -\-name healthcheck andrius/alpine-ruby /bin/sh 
    docker cp deploy/healthcheck.rb healthcheck:/healthcheck.rb
-->

### Run tests

There's a load test provided as a service in this compose file. For more information see [Load Test](#loadtest).  
It will run when the compose is started up, after a delay of 60s. This is a load test provided to simulate user traffic to the application.
This will send some traffic to the application, which will form the connection graph that you view in Scope or Weave Cloud. 

<!-- deploy-test-hidden run-tests
    
    docker exec -t healthcheck ruby /healthcheck.rb -s user,catalogue,queue-master,cart,shipping,payment,orders -d 90
    if [ $? -ne 0 ]; then 
        docker rm -f healthcheck 
        exit 1; 
    fi
    docker rm -f healthcheck 

-->

### Cleaning up

<!-- deploy-test-start destroy-infrastructure -->

    docker-compose -f deploy/docker-compose/docker-compose.yml down
   
<!-- deploy-test-end -->
