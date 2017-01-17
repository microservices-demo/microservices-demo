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

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```

<!-- deploy-doc-start pre-install -->

    curl -sSL https://get.docker.com/ | sh
    apt-get install -yq python-pip build-essential python-dev
    pip install docker-compose
    curl -L git.io/weave -o /usr/local/bin/weave
    chmod a+x /usr/local/bin/weave

<!-- deploy-doc-end -->

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

<!-- deploy-doc-start create-infrastructure -->

    weave launch
    docker-compose -f deploy/docker-compose-weave/docker-compose.yml up -d

<!-- deploy-doc-end -->

### Run tests

There's a load test provided as a service in this compose file. For more information see [Load Test](#loadtest). 
It will run when the compose is started up, after a delay of 60s. This is a load test provided to simulate user traffic to the application. 
This will send some traffic to the application, which will form the connection graph that you view in Scope or Weave Cloud. 

<!-- deploy-doc-hidden run-tests

    docker build -t healthcheck -f deploy/Dockerfile-healthcheck deploy/.
    docker create -t -\-name healthcheck healthcheck -s user,catalogue,queue-master,cart,shipping,payment,orders -d 120 -r 5
    docker network connect dockercomposeweave_secure healthcheck
    docker network connect dockercomposeweave_internal healthcheck
    docker network connect dockercomposeweave_external healthcheck
    docker network connect dockercomposeweave_backoffice healthcheck
    docker start -a healthcheck

    if [ $? -ne 0 ]; then
        docker rm healthcheck
        exit 1;
    fi
    docker rm healthcheck

-->

### Opentracing

Zipkin is part of the deployment and has been written into some of the services.  While the system is up you can view the traces in
Zipkin at http://localhost:9411.  Currently orders provide the most comprehensive traces.

### Cleaning up

<!-- deploy-doc-start destroy-infrastructure -->

    docker-compose -f deploy/docker-compose-weave/docker-compose.yml down
    weave stop

<!-- deploy-doc-end -->
