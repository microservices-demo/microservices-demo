[![Build Status](https://travis-ci.org/microservices-demo/microservices-demo.svg?branch=master)](https://travis-ci.org/microservices-demo/microservices-demo)

# Sock Shop : A Microservice Demo Application

The application is the user-facing part of an online shop that sells socks. It is intended to aid the demonstration and testing of microservice and cloud native technologies.

It is built using [Spring Boot](http://projects.spring.io/spring-boot/), [Go kit](http://gokit.io) and [Node.js](https://nodejs.org/) and is packaged in Docker containers.

You can read more about the [application design](./internal-docs/design.md).

## Deployment Platforms

The [deploy folder](./deploy/) contains scripts and instructions to provision the application onto your favourite platform. 

Please let us know if there is a platform that you would like to see supported.

## Bugs, Feature Requests and Contributing

We'd love to see community contributions. We like to keep it simple and use Github issues to track bugs and feature requests and pull requests to manage contributions. See the [contribution information](.github/CONTRIBUTING.md) for more information.

## Screenshot

![Sock Shop frontend](https://github.com/microservices-demo/microservices-demo.github.io/raw/master/assets/sockshop-frontend.png)

## Visualizing the application

Use [Weave Scope](http://weave.works/products/weave-scope/) or [Weave Cloud](http://cloud.weave.works/) to visualize the application once it's running in the selected [target platform](./deploy/).

![Sock Shop in Weave Scope](https://github.com/microservices-demo/microservices-demo.github.io/raw/master/assets/sockshop-scope.png)

## 

######
version: '2'
services:
  front-end:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-front-end
    ports:
      - '80:8079'
    environment:
      - reschedule=on-node-failure
  catalogue:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-catalogue
    environment:
      - reschedule=on-node-failure
  catalogue-db:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-catalogue-db
    environment:
      - reschedule=on-node-failure
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_ALLOW_EMPTY_PASSWORD=true
      - MYSQL_DATABASE=socksdb
  cart:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-cart
    environment:
      - reschedule=on-node-failure
  cart-db:
    image: mongo
    environment:
      - reschedule=on-node-failure
  orders:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-orders
    environment:
      - reschedule=on-node-failure
  orders-db:
    image: mongo
    environment:
      - reschedule=on-node-failure
  shipping:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-shipping
    environment:
      - reschedule=on-node-failure
  rabbitmq:
    image: rabbitmq:3
    environment:
      - reschedule=on-node-failure
  payment:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-payment
    environment:
      - reschedule=on-node-failure
  user:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-user
    environment:
      - MONGO_HOST=user-db:27017
      - reschedule=on-node-failure
  user-db:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-user-db
    environment:
      - reschedule=on-node-failure
  user-sim:
    image: registry.aliyuncs.com/slzcc/weaveworksdemos-load-test
    command: "-d 60 -r 200 -c 2 -h front-end"
