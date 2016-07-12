# Weave Demo on Docker Swarm

The Weave Demo application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file.

## Pre-requisites

- Install Docker
- Install [Weave Net](https://www.weave.works/products/install-weave-net/)
- Install [Weave Scope](https://www.weave.works/products/install-weave-scope/)

## Install & run

Launch Weave Net on each host. There are [instructions for preparing a Swarm](../../install/docker-machine-swarm) specific to this demo.

    curl -L https://raw.githubusercontent.com/weaveworks/weaveDemo/master/deploy/docker-swarm/docker-compose.yml -o docker-compose.yml
    docker-compose up -d

## Launch Weave Cloud

On each Swarm host, launch Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    scope launch --service-token=<token>

## Load test

There's a load test provided to simulate user traffic to the application.

    docker run weaveworksdemos/load-test -h http://localhost/ -r 100 -c 2

This will send some traffic to the application, which will form the connection graph that you view in Scope or Weave Cloud.


