[![Build Status](https://travis-ci.org/microservices-demo/microservices-demo.svg?branch=master)](https://travis-ci.org/microservices-demo/microservices-demo)

# Sock Shop : A Microservice Demo Application

## General

The application is the user-facing part of an online shop that sells socks. It is intended to aid the demonstration and testing of microservice and cloud native technologies.

It is built using [Spring Boot](http://projects.spring.io/spring-boot/), [Go kit](http://gokit.io) and [Node.js](https://nodejs.org/) and is packaged in Docker containers.

## Useful links

- Documentation site: [website](https://microservices-demo.github.io/)
- Application design: [website](./internal-docs/design.md).
- Google Cloud Kubernetes installation: [website](./deploy/kubernetes/terraform/gcp/README.md)

## Services 

| Project   | Tech Stack | Fork | Original Github  | Docker hub  |
|-----------|------------|------|------------------|-------------|
| front-end | Node.js    | [link](https://github.com/TUB-CNPE-TB/front-end) | [link](https://github.com/microservices-demo/front-end) | [link](https://hub.docker.com/r/weaveworksdemos/front-end/)  |
| edge-router | traefik | -- | [edge-router](https://github.com/microservices-demo/edge-router)  | [link](https://hub.docker.com/r/weaveworksdemos/edge-router/)  |
| catalogue  | Go       | [link](https://github.com/TUB-CNPE-TB/catalogue) | [link](https://github.com/microservices-demo/catalogue)  | [link](https://hub.docker.com/r/weaveworksdemos/catalogue/)  |
| catalogue-db | mysql | --  | --  | [link](https://hub.docker.com/r/weaveworksdemos/catalogue-db/)  |
| carts  | Java Spring boot | [link](https://github.com/TUB-CNPE-TB/carts) | [link](https://github.com/microservices-demo/carts)  | [link](https://hub.docker.com/r/weaveworksdemos/carts/)  |
| carts-db, orders-db | MongoDB | --  | --  | [link](https://hub.docker.com/_/mongo)  |
| orders  | Java Spring boot | [link](https://github.com/TUB-CNPE-TB/orders) | [link](https://github.com/microservices-demo/orders)  | [link](https://hub.docker.com/r/weaveworksdemos/orders/)  |
| shipping  | Java Spring boot | [link](https://github.com/TUB-CNPE-TB/shipping) | [link](https://github.com/microservices-demo/shipping)  | [link](https://hub.docker.com/r/weaveworksdemos/shipping/)  |
| queue-master  | Java Spring boot | [link](https://github.com/TUB-CNPE-TB/queue-master) | [link](https://github.com/microservices-demo/queue-master)  | [link](https://hub.docker.com/r/weaveworksdemos/queue-master/)  |
| rabbitmq  | RabbitMQ | --  | --  | [link](https://hub.docker.com/_/rabbitmq)  |
| payment  | Go | [link](https://github.com/TUB-CNPE-TB/payment) |  [link](https://github.com/microservices-demo/payment)  | [link](https://hub.docker.com/r/weaveworksdemos/payment/)  |
| user  | Go | [link](https://github.com/TUB-CNPE-TB/user) | [link](https://github.com/microservices-demo/user)  | [link](https://hub.docker.com/r/weaveworksdemos/user/)  |
| user-db | MongoDB | --  | --  | [link](https://hub.docker.com/r/weaveworksdemos/user-db/)  |
| load-test  | Python | [link](https://github.com/TUB-CNPE-TB/load-test) | [link](https://github.com/microservices-demo/load-test)  | [link](https://hub.docker.com/r/weaveworksdemos/load-test/)  |
| session-db  | Redis | --  | [link](https://hub.docker.com/_/redis)  |

## Quick start with minikube

1. Start minikube: `minikube start --vm-driver=hyperkit --cpus 6 --memory 8192`
1. Go to the folder deploy/kubernetes/manifest and execute: `kubectl apply -f .`
1. In another terminal/console, run `minikube tunnel`
1. Get the external ip address using `kubectl get svc front-end`
1. To get metrics in minikube install this `minikube addons enable metrics-server` and display dashboar with `minikube dashboard`
1. Finally, to end execute `minikube stop` and delete with `minikube delete`

## Istio configuration

1. istioctl install
1. kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/kiali.yaml
1. kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/jaeger.yaml
1. kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/prometheus.yaml
1. kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/grafana.yaml
1. k port-forward svc/kiali 20001 -n istio-system
1. Follow terraform gcp instructions (create gke, install k8s apps, do load test)

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
