---
layout: default
---

## Sock Shop on Minikube

This demo demonstrates running the Sock Shop on Minikube.

### Pre-requisites
* Install [Minikube](https://github.com/kubernetes/minikube)
* Install [kubectl] (http://kubernetes.io/docs/user-guide/prereqs/)

### Clone the microservices-demo repo 

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```

### Start Minikube

You can start Minikube by running:

```
minikube start
```

Check if it's running with `minikube status`, and make sure the Kubernetes dashboard is running on http://192.168.99.100:30000.

### Deploy Sock Shop

Deploy the Sock Shop application on Minikube

```
kubectl create -f deploy/kubernetes/manifests/sock-shop-ns.yml -f deploy/kubernetes/manifests
```

Wait for all the Sock Shop services to start:

```
kubectl get pods --namespace="sock-shop"
```

### Check the Sock Shop webpage

Once the application is deployed, navigate to http://192.168.99.100:30001 to see the Sock Shop home page.

### Run tests

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud.

```
docker run --rm weaveworksdemos/load-test -d 5 -h http://192.168.99.100:30001 -c 3 -r 10
```

### Uninstall the Sock Shop application

```
kubectl delete -f deploy/kubernetes/manifests/sock-shop-ns.yml -f deploy/kubernetes/manifests
```

If you don't need the Minikube instance anymore you can delete it by running:

```
minikube delete
```
