# Sock Shop on Docker

The Sock Sho application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file.
*This version does not use any custom networks*.
DNS is achieved by using the internal Docker DNS, which reads network alias entries provided by docker-compose.

## Pre-requisites

- Install Docker
- Install [Weave Scope](https://www.weave.works/install-weave-scope/)

## Install & run

    curl -L https://raw.githubusercontent.com/microservices-demo/microservices-demo/master/deploy/docker-only/docker-compose.yml -o docker-compose.yml
    docker-compose up -d

## Launch Weave Scope or Weave Cloud

Weave Scope (local instance)

    scope launch

Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    scope launch --service-token=<token>

## Load test

There's a load test provided as a service in this compose file.
It will run when the compose is started up, after a delay of 60s.
