# Sock Shop on Docker

The Sock Shop application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file.
*This version does not use any custom networks*.
DNS is achieved by using the internal Docker DNS, which reads network alias entries provided by docker-compose.

## Prerequisites
 
 - Install Docker
 - Install [Weave Scope](https://www.weave.works/install-weave-scope/)

## Pre install

<!-- deploy-test preinstall -->

    curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
 
<!-- deploy-test-end -->

## Provision infrastructure

<!-- deploy-test-start create-infrastructure -->

    docker-compose run -d user-db
    docker-compose run -d user
    docker-compose run -d catalogue-db
    docker-compose run -d catalogue
    docker-compose run -d rabbitmq
    docker-compose run -d queue-master
    docker-compose run -d cart-db
    docker-compose run -d cart
    docker-compose run -d orders-db
    docker-compose run -d shipping
    docker-compose run -d payment
    docker-compose run -d orders
    docker-compose run -d front-end
    docker-compose run -d edge-router
    
<!-- deploy-test-end -->

## Run tests

Run the user similator load test. For more information see [Load Test](#loadtest)

<!-- deploy-test-start run-tests -->

    docker-compose run -d user-sim

<!-- deploy-test-end -->

## Cleaning up

<!-- deploy-test-start destroy-infrastructure -->

    docker-compose kill
    docker-compose rm -f

<!-- deploy-test-end -->

## Launch Weave Scope or Weave Cloud

Weave Scope (local instance)
    sudo curl -L git.io/scope -o /usr/local/bin/scope
    sudo chmod a+x /usr/local/bin/scope
    scope launch
    scope launch

Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    scope launch --service-token=<token>

## Load test

This compose file contains a load test which will be run to test to entire system.
It will run when the compose is started up, after a delay of 60s.