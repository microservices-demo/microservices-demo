# Weave Demo on Docker (single-host)

The Weave Demo application is packaged using a [Docker Compose](https://docs.docker.com/compose/) file. This version creates several isolated networks using the weave docker plugin driver.

## Pre-requisites

- Install Docker
- Install [Weave Net](https://www.weave.works/install-weave-net/)
- Install [Weave Scope](https://www.weave.works/install-weave-scope/)

## Install & run

    weave launch
    curl -L https://raw.githubusercontent.com/weaveworks/weaveDemo/master/deploy/docker-single/docker-compose.yml -o docker-compose.yml
    docker-compose up -d

## Launch Weave Scope or Weave Cloud

Weave Scope (local instance)

    scope launch

Weave Cloud (hosted platform). Get a token by [registering here](http://cloud.weave.works/).

    scope launch --service-token=<token>

## Load test

There's a load test provided to simulate user traffic to the application.

    docker run weaveworksdemos/load-test -h http://localhost/ -r 100 -c 2

This will send some traffic to the application, which will form the connection graph that you view in Scope or Weave Cloud.


